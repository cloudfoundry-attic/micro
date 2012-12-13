require 'spec_helper'

describe VCAP::Micro::InternetConnection do

  describe '#connected?' do

    it 'is not connected when the file exists' do
      temp = Tempfile.new('internet_connection')
      ic = VCAP::Micro::InternetConnection.new(temp.path)
      ic.should_not be_connected
    end

    it 'is connected when the file does not exist' do
      ic = VCAP::Micro::InternetConnection.new('/this/file/does/not/exist')
      ic.should be_connected
    end

  end

  describe '#set_connected' do

    it 'connects' do
      temp = Tempfile.new('internet_connection')
      ic = VCAP::Micro::InternetConnection.new(temp.path)

      dnsmasq = double('dnsmasq')
      dnsmasq.should_receive(:restore_upstream_servers)
      VCAP::Micro::Dnsmasq.stub(:new) { dnsmasq }

      ic.set_connected
      ic.should be_connected
    end

  end

  describe '#set_disconnected' do

    it 'disconnects' do
      temp = Tempfile.new('internet_connection')
      ic = VCAP::Micro::InternetConnection.new(temp.path)

      dnsmasq = double('dnsmasq')
      dnsmasq.should_receive(:remove_upstream_servers)
      VCAP::Micro::Dnsmasq.stub(:new) { dnsmasq }

      ic.set_disconnected

      ic.should_not be_connected
    end

  end

end
