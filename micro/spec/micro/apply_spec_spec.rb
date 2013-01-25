require 'spec_helper'

describe VCAP::Micro::ApplySpec do

  describe '#path' do

    it 'sets the path' do
      subject.path = 'foo'
      subject.path.should == 'foo'
    end

  end

  context 'writing and reading' do

    subject {
      temp = Tempfile.new('apply_spec')
      path = temp.path
      temp.unlink

      as = VCAP::Micro::ApplySpec.new(path)
      as.domain = 'test.com'
      as.http_proxy = 'http://proxy.test.com:1234'

      as.properties['ccdb'] = {
        'roles' => [
                    { 'tag' => 'acm' },
                    { 'tag' => 'admin' },
                    { 'tag' => 'uaa' },
                   ]
      }

      as.properties['ccdb_ng'] = as.properties['ccdb'].dup

      as.properties['acmdb'] = {
        'roles' => [
                    { 'tag' => 'admin' },
                    { 'tag' => 'acm' },
                   ],
      }
      as.properties['uaadb'] = {
        'roles' => [
                    { 'tag' => 'admin' },
                   ]
      }
      as.properties['service_lifecycle'] = {
        'resque' => {}
      }
      as.properties['vcap_redis'] = {}
      as.properties['uaa'] = {}

      as.write

      VCAP::Micro::ApplySpec.new(path).read
    }

    its(:domain) { should == 'test.com' }

    its(:env) { should include({
      'http_proxy' => 'http://proxy.test.com:1234',
      'https_proxy' => 'http://proxy.test.com:1234',
      'no_proxy' => '.test.com,127.0.0.1/8,localhost',
      })
    }

  end

  context 'exception during write' do

    it 'should preserve the original file' do
      temp = Tempfile.new('apply_spec')

      as = VCAP::Micro::ApplySpec.new(temp.path)

      as.properties['ccdb'] = {
        'roles' => [
                    { 'tag' => 'acm' },
                    { 'tag' => 'admin' },
                    { 'tag' => 'uaa' },
                   ]
      }
      as.properties['ccdb_ng'] = as.properties['ccdb'].dup

      as.properties['acmdb'] = {
        'roles' => [
                    { 'tag' => 'admin' },
                    { 'tag' => 'acm' },
                   ],
      }
      as.properties['uaadb'] = {
        'roles' => [
                    { 'tag' => 'admin' },
                   ]
      }
      as.properties['service_lifecycle'] = {
        'resque' => {}
      }
      as.properties['vcap_redis'] = {}
      as.properties['uaa'] = {}

      as.write do |a|
        a.domain = 'test.com'
        a.http_proxy = 'http://proxy.test.com:1234'
      end

      orig_content = open(temp.path).read

      begin
        as.write { |c| raise 'derp' }
      rescue Exception
      end

      new_content = open(temp.path).read

      temp.unlink

      new_content.should == orig_content
    end

  end

  describe '#http_proxy=' do

    context 'using a proxy' do

      subject {
        as = VCAP::Micro::ApplySpec.new
        as.domain = 'test.com'
        as.http_proxy = 'http://proxy.test.com:1234'
        as
      }

      its(:env) {
        should include 'http_proxy' => 'http://proxy.test.com:1234'
      }

      its(:env) {
        should include 'https_proxy' => 'http://proxy.test.com:1234'
      }

      its(:env) {
        should include 'no_proxy' => '.test.com,127.0.0.1/8,localhost'
      }

    end

    context 'not using a proxy' do

      subject {
        as = VCAP::Micro::ApplySpec.new
        as.http_proxy = nil
        as
      }

      its(:env) { should_not include 'http_proxy' }

      its(:env) { should_not include 'https_proxy' }

      its(:env) { should_not include 'no_proxy' }

    end

  end

end
