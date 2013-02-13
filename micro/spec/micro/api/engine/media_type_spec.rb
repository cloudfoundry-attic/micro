require 'spec_helper'

describe VCAP::Micro::Api::Engine::MediaType do

  class TestMediaType1 < VCAP::Micro::Api::Engine::MediaType

    MEDIA_TYPE = 'application/vnd.vmware.media-type-1+json'.freeze

    def initialize(fields={})
      super fields

      @field1 = fields[:field1]
    end

    attr_accessor :field1
  end

  class TestMediaType2 < VCAP::Micro::Api::Engine::MediaType

    MEDIA_TYPE = 'application/vnd.vmware.media-type-2+json'.freeze

    def initialize(fields={})
      super fields

      @field1 = fields[:field1]
    end

    attr_accessor :field1
  end

  class TestMediaType3 < VCAP::Micro::Api::Engine::MediaType

    MEDIA_TYPE = 'application/vnd.vmware.media-type-3+json'.freeze

    Links = {
      :rel1 => [:get,  TestMediaType1],
      :rel2 => [:post, TestMediaType2],
    }

    def initialize(fields={})
      super fields

      @field1 = fields[:field1]
      @field2 = fields[:field2]
      @field3 = fields[:field3]
      @field4 = fields[:field4]
    end

    attr_accessor :field1
    attr_accessor :field2
    attr_accessor :field3
    attr_accessor :field4
  end

  describe '#link' do

    context 'when the link has a valid rel' do
      subject do
        mt = TestMediaType3.new
        mt.link(:rel1, 'test')
      end

      its(:_links) { should include(
        {
          :rel1 => {
            :method => TestMediaType3::Links[:rel1][0],
            :href => 'test',
            :type => TestMediaType3::Links[:rel1][1]::MEDIA_TYPE
          }
        })
      }
    end

    context 'when the link has an invalid rel' do
      subject { TestMediaType3.new }
      it { lambda { link(:invalid_rel, 'test') }.should raise_exception }
    end

  end

  describe '.subclasses' do

    subject { VCAP::Micro::Api::Engine::MediaType }

    its(:subclasses) {
      should include(TestMediaType1, TestMediaType2, TestMediaType3)
    }

  end

  describe '#json_create' do

    subject do
      json = {
        :json_class => 'TestMediaType3',
        :data => {
          :field1 => 'a',
          :field2 => 2,
          :field3 => [3, ],
          :field4 => { 'd' => 4 }
        }
      }.to_json

      JSON.parse(json, :create_additions => true)
    end

    it { should be_a TestMediaType3 }

    its(:field1) { should == 'a' }
    its(:field2) { should == 2 }
    its(:field3) { should == [3, ] }
    its(:field4) { should == { 'd' => 4 } }
  end

  describe '.from_content_type' do

    it 'gets the correct content type' do
      VCAP::Micro::Api::Engine::MediaType.from_content_type(
        TestMediaType1::MEDIA_TYPE).should == TestMediaType1
    end
  end

  describe '#to_json' do

    subject {
      json = TestMediaType3.new(
        :field1 => 'a',
        :field2 => 2,
        :field3 => [3, ],
        :field4 => { 'd' => 4 }
      ).to_json

      JSON.parse(json)
    }

    it { should == {
        '_links' => {},
      'field1' => 'a',
      'field2' => 2,
      'field3' => [3, ],
      'field4' => { 'd' => 4 }
      }
    }
  end

  describe '#each' do

    subject { TestMediaType1.new(:field1 => 'abc') }

    specify {
      expect { |b| subject.each(&b) }.to yield_with_args(
        {'_links' => {}, 'field1' => 'abc' }.to_json)
    }
  end

end
