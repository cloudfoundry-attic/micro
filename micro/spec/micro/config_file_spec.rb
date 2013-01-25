require 'spec_helper'

describe VCAP::Micro::ConfigFile do

  context 'setting the path' do

    it 'sets the path' do
      subject.path = 'foo'
      subject.path.should == 'foo'
    end

    it "doesn't exist" do
      subject.path = '/tmp/a/file/that/does/not/exist'
      subject.should_not exist
    end

    it 'is not configured' do
      subject.path = '/tmp/a/file/that/does/not/exist'
      subject.should_not be_configured
    end

  end

  context 'writing and reading' do

    subject {
      temp = Tempfile.new('config_file')
      path = temp.path
      temp.unlink

      cf = VCAP::Micro::ConfigFile.new(path)
      cf.write do |c|
        c.api_host = 'test.com'
        c.cloud = 'cloud'
        c.ip = '192.168.0.1'
        c.name = 'apitest'
        c.token = 'token'
      end

      VCAP::Micro::ConfigFile.new(path)
    }

    its(:api_host) { should == 'test.com' }

    its(:cloud) { should == 'cloud' }

    its(:ip) { should == '192.168.0.1' }

    its(:name) { should == 'apitest' }

    its(:token) { should == 'token' }

    its(:subdomain) { should == 'apitest.cloud' }

  end

  context 'exception during write' do

    it 'should preserve the original file' do
      temp = Tempfile.new('config_file')

      cf = VCAP::Micro::ConfigFile.new
      cf.path = temp.path

      cf.write do |c|
        c.api_host = 'test.com'
        c.cloud = 'cloud'
        c.ip = '192.168.0.1'
        c.name = 'apitest'
        c.token = 'token'
      end

      orig_content = open(temp.path).read

      expect {
        cf.write { |c| raise 'derp' }
      }.to raise_error

      new_content = open(temp.path).read

      temp.unlink

      new_content.should == orig_content
    end

  end

end
