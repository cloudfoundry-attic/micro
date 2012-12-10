require 'micro/monitored_process'
require 'micro/monitored_process_group'
require 'micro/service_config'

describe VCAP::Micro::MonitoredProcessGroup do

  describe '#stop' do

    it 'stops all of its process' do
      mpg = VCAP::Micro::MonitoredProcessGroup.new('g1', [
        VCAP::Micro::MonitoredProcess.new('p1'),
        VCAP::Micro::MonitoredProcess.new('p2')
      ])

      mpg.processes.each { |p| p.should_receive(:stop) }
      mpg.stop
    end

  end

  describe "#enabled?" do

    context 'enabled' do

      it 'is enabled' do
        VCAP::Micro::ServiceConfig.stub(:new) { double(:'enabled?' => true) }
        VCAP::Micro::MonitoredProcessGroup.new('g1', []).should be_enabled
      end

    end

    context 'disabled' do

      it 'is disabled' do
        VCAP::Micro::ServiceConfig.stub(:new) { double(:'enabled?' => false) }
        VCAP::Micro::MonitoredProcessGroup.new('g1', []).should_not be_enabled
      end

    end

  end

  describe "#running?" do

    context 'enabled and all running' do

      it 'is running' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1',
          [double(:'running?' => true)])

        mpg.should_receive(:'enabled?').and_return(true)

        mpg.running?(nil).should be_true
      end

    end

    context 'disabled' do

      it 'is not running' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1', [])

        mpg.should_receive(:'enabled?').and_return(false)

        mpg.running?(nil).should be_false
      end

    end

    context 'enabled and one process not running' do

      it 'is not running' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1',
          [double(:'running?' => true), double(:'running?' => false)])

        mpg.should_receive(:'enabled?').and_return(true)

        mpg.running?(nil).should be_false
      end

    end

  end

  describe '#status_hash' do

    context 'enabled and running' do

      it 'is enabled and ok' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1', [])

        mpg.should_receive(:'enabled?').and_return(true)
        mpg.should_receive(:'running?').and_return(true)

        mpg.status_hash(nil).should == { :enabled => true, :health => :ok }
      end

    end

    context 'enabled and not running' do

      it 'is enabled and failed' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1', [])

        mpg.should_receive(:'enabled?').and_return(true)
        mpg.should_receive(:'running?').and_return(false)

        mpg.status_hash(nil).should ==
          { :enabled => true, :health => :failed }
      end

    end

    context 'disabled' do

      it 'is disabled and failed' do
        mpg = VCAP::Micro::MonitoredProcessGroup.new('g1', [])

        mpg.should_receive(:'enabled?').and_return(false)
        mpg.should_receive(:'running?').and_return(false)

        mpg.status_hash(nil).should ==
          { :enabled => false, :health => :failed }
      end

    end

  end

end
