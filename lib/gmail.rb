require 'net/imap'
require 'net/smtp'
require 'smtp_tls'

class Gmail
  VERSION = '0.0.1'

  attr_reader :imap

  def initialize(username, password)
    # This is to hide the username and password, not like it REALLY needs hiding, but ... you know.
    meta = class << self
      class << self
        attr_accessor :username, :password
      end
      self
    end
    meta.username = username
    meta.password = password
    @imap = Net::IMAP.new('imap.gmail.com',993,true)
    @connected = true if @imap.login(username, password)
    at_exit { logout if @connected }
  end

  # Accessors for IMAP things
  def mailbox(name)
    mailboxes[name] ||= Mailbox.new(self, name)
  end

  # Accessors for Gmail things
  def inbox
    mailbox('inbox')
  end
  # Log out of gmail
  def logout
    @connected = false if @imap.logout
  end

  def in_mailbox(mailbox, &block)
    raise ArgumentError, "Must provide a code block" unless block_given?
    mailbox_stack << mailbox
    unless @selected == mailbox.name
      @gmail.imap.select(mailbox.name)
      @selected = mailbox.name
    end
    value = block.arity == 1 ? block.call(mailbox) : block.call
    mailbox_stack.pop
    # Select previously selected mailbox if there is one
    if mailbox_stack.last
      @gmail.imap.select(mailbox_stack.last.name)
      @selected = mailbox.name
    end
    return value
  end

  def open_smtp(&block)
    raise ArgumentError, "This method is to be used with a block." unless block_given?
    meta = class << self; self end
    puts "Opening SMTP..."
    Net::SMTP.start('smtp.gmail.com', 587, 'localhost.localdomain', meta.username, meta.password, 'plain', true) do |smtp|
      puts "SMTP open."
      block.call(lambda {|to, body|
        from = meta.username =~ /@/ ? meta.username : meta.username + '@gmail.com'
        puts "Sending from #{from} to #{to}:\n#{body}"
        smtp.send_message(body, from, to)
      })
      puts "SMTP closing."
    end
    puts "SMTP closed."
  end
  
  def send_email(to, body=nil)
    meta = class << self; self end
    if to.is_a?(MIME::Message)
      to.headers['from'] = meta.username =~ /@/ ? meta.username : meta.username + '@gmail.com'
      body = to.to_s
      to = to.to
    end
    raise ArgumentError, "Please supply (to, body) to Gmail#send_email" if body.nil?
    open_smtp do |smtp|
      smtp.call to, body
    end
  end
  
  private
    def mailboxes
      @mailboxes ||= {}
    end
    def mailbox_stack
      @mailbox_stack ||= []
    end
end

require 'gmail/mailbox'
require 'gmail/message'