require 'spec_helper'
require 'micro/settings'

describe VCAP::Micro::Network do

  let(:props) {
    {
      'ccdb' => {
        'roles' => [
                    { 'tag' => 'acm' },
                    { 'tag' => 'admin' },
                    { 'tag' => 'uaa' },
                   ] },
      'acmdb' => {
        'roles' => [
                    { 'tag' => 'admin' },
                    { 'tag' => 'acm' },
                   ] },
      'uaadb' => {
        'roles' => [
                    { 'tag' => 'admin' },
                   ] },
      'service_lifecycle' => {
        'resque' => {}
      },
      'vcap_redis' => {},
      'uaa' => {},
    }
  }

  it "should set a random password at the first invocation" do
    VCAP::Micro::Settings.randomize_passwords(props)
    props['mysql_node']['password'].should_not be_nil
  end

  it "should not set a random password at the sequent invocations" do
    VCAP::Micro::Settings.randomize_passwords(props)
    p1 = props['mysql_node']['password']
    VCAP::Micro::Settings.randomize_passwords(props)
    p2 = props['mysql_node']['password']
    p1.should == p2
  end

end
