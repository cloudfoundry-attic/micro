require 'spec_helper'

describe VCAP::Micro::Console do
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:console) { VCAP::Micro::Console.new(input, output) }
  let(:configured) { false }
  let(:identity) do
    identity = mock(:identity)
    identity.stub(:subdomain) { "some_subdomain" }
    identity.stub(:ip) { ip }
    identity.stub(:admins) { nil }
    identity.stub(:configured?) { configured }
    identity.stub(:api_host) { 'mcapi.cloudfoundry.com' }
    identity
  end
  let(:ip) { "192.168.1.0" }

  describe '#console' do
    subject { console.console }

    before do
      VCAP::Micro::Identity.stub(:new) { identity }
      VCAP::Micro::Network.stub(:local_ip) { ip }
    end

    context 'when not configured' do
      before do
        input.write "5\n" #quit
        input.rewind
      end

      it 'includes the welcome text' do
        subject

        output.rewind
        output.read.should include <<-CONSOLE.chomp.strip_heredoc
        Welcome to VMware Micro Cloud Foundry version 1.2.0

        To configure go to http://#{ip}:9292/ in your browser.
        CONSOLE
      end

      it 'include the limited set of command line configuration' do
        subject

        output.rewind
        output.read.should include <<-CONSOLE.chomp.strip_heredoc
        1. Reconfigure network
        2. Restart network
        3. Troubleshoot network
        4. Help

        Select option:#{' '}
        CONSOLE
      end

      it 'includes the not configured configuration' do
        subject

        console_output = output.rewind && output.read
        console_output.should_not include "Current Configuration"
        console_output.should_not include "Identity:"
        console_output.should_not include "Admin:"
        console_output.should_not include "IP Address:"
        console_output.should_not include "To access your Micro Cloud Foundry instance, use:"
        console_output.should_not include "vmc target http://api.some_subdomain"
      end

    end

    it 'catches and logs exceptions' do

    end

    context 'when configured' do
      it 'starts the micro agent' do

      end
    end

    context 'when not configured' do
      it 'does not start the micro agent' do

      end
    end
  end
end