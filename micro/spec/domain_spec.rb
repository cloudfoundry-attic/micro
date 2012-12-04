require 'micro/domain'

describe VCAP::Micro::Domain do

  it 'detects that a valid domain is valid' do
    VCAP::Micro::Domain.new('test.com').should be_valid
  end

  it 'allows a domain starting with a digit' do
    VCAP::Micro::Domain.new('1test.com').should be_valid
  end

  it 'detects that a nil domain is invalid' do
    VCAP::Micro::Domain.new(nil).should_not be_valid
  end

  it 'detects that an empty string domain is invalid' do
    VCAP::Micro::Domain.new('').should_not be_valid
  end

  it 'detects that an invalid domain is invalid' do
    VCAP::Micro::Domain.new('foo').should_not be_valid
  end

  it 'does not allow a domain starting with a hyphen' do
    VCAP::Micro::Domain.new('-foo.com').should_not be_valid
  end

  it 'does not allow a domain part ending with a hyphen' do
    VCAP::Micro::Domain.new('foo-.com').should_not be_valid
  end

end
