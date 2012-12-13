require 'spec_helper'

describe VCAP::Micro::MonitoredProcessGroups do

  let (:yaml) {
    <<-eos
---
g1:
  - p1
  - p2
g2:
  - p3
  - p4
eos
  }

  subject {
    Tempfile.open('monitored_process_groups') do |temp|
      temp.write(yaml)
      temp.flush

      VCAP::Micro::MonitoredProcessGroups.new(:path => temp.path).read
    end
  }

  describe '#read' do

    specify { subject.group('g1').processes[0].name.should == 'p1' }

    specify { subject.group('g1').processes[1].name.should == 'p2' }

    specify { subject.group('g2').processes[0].name.should == 'p3' }

    specify { subject.group('g2').processes[1].name.should == 'p4' }

  end

  describe '#group' do

    specify { subject.group('g1').should
      be_a(VCAP::Micro::MonitoredProcessGroup)
    }

  end

end
