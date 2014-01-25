require 'spec_helper'

describe Gmail do

  it 'initializes' do
    imap = double
    Net::IMAP.should_receive(:new)
      .with('imap.gmail.com', 993, true, nil, false)
      .and_return(imap)
    gmail = Gmail.new('test', 'password')
  end

  xit 'logins if disconnected' do
    setup_mocks(at_exit: true)

    @imap.stub(:disconnected?) { true }
    @imap.should_receive(:login).with('test@gmail.com', 'password')
    @gmail.imap
  end

  xit 'does login only once' do
    setup_mocks(at_exit: true)

    @imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with('test@gmail.com', 'password')
    @gmail.imap
    @gmail.imap
    @gmail.imap
  end

  xit 'logins without appending gmail domain' do
    setup_mocks(at_exit: true)

    @imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with('test@gmail.com', 'password')
    @gmail.imap
  end

  xit 'logs_out' do
    setup_mocks(at_exit: true)

    @imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with('test@gmail.com', 'password')
    @gmail.imap
    @imap.expects(:logout).returns(true)
    @gmail.logout
  end

  xit 'does nothing if not logged_in when logged out' do
    setup_mocks

    @imap.expects(:disconnected?).returns(true)
    @imap.expects(:logout).never
    @gmail.logout
  end

  xit 'creates a label' do
    setup_mocks(at_exit: true)
    @imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    @imap.expects(:login).with('test@gmail.com', 'password')
    @imap.expects(:create).with('foo')
    @gmail.create_label('foo')
  end

private

  def setup_mocks(options = {})
    options = { at_exit: false }.merge(options)

    @imap = double
    Net::IMAP.should_receive(:new)
      .with('imap.gmail.com', 993, true, nil, false)
      .and_return(@imap)
    @gmail = Gmail.new('test@gmail.com', 'password')

    # need this for the at_exit block that auto-exits after this test method completes
    # @imap.should_receive(:logout).once if options[:at_exit]
  end

end
