require 'micro/local_ip'

describe VCAP::Micro do

  describe '#local_ip' do

    it 'returns the local IP address' do
      VCAP::Micro.local_ip.should_not be_nil
    end

  end

end
