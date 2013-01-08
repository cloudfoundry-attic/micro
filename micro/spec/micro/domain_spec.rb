require 'spec_helper'

describe VCAP::Micro::Domain do
  subject { VCAP::Micro::Domain.new(url) }

  context "when valid url is passed" do

    %w{test.com vcap.me 1test.com}.each do |url|
      context "when url is #{url}" do
        let(:url) { url }
        it { should be_valid }
      end
    end
  end

  context "when invalid url is passed" do
    [nil, '', 'foo', '-foo.com', 'foo-.com', 'test.a'].each do |url|
      context "when url is #{url}" do
        let(:url) { url }
        it { should_not be_valid }
      end
    end
  end
end
