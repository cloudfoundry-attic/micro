require 'tempfile'

require 'micro/dnsmasq'

describe VCAP::Micro::Dnsmasq do

  subject { VCAP::Micro::Dnsmasq.new('foobar.com', '192.168.0.2') }

  its(:gen_conf) { should == 'address=/foobar.com/192.168.0.2' }

  its(:gen_enter_hook) { should == <<-eos
if [ "$reason" = "BOUND" ]; then
  echo "address=/foobar.com/$new_ip_address" > /etc/dnsmasq.conf

  for ns in $new_domain_name_servers
  do
    if [ -e "/var/vcap/micro/offline" ]; then
      echo "# server=$ns"
    else
      echo "server=$ns"
    fi
  done > /etc/dnsmasq.d/server

  service dnsmasq restart
fi
eos
  }

  its(:gen_resolv_conf) { should == <<-eos
make_resolv_conf() {
  echo 'nameserver 127.0.0.1' > /etc/resolv.conf
}
eos
    }

  describe '.write' do

    before(:all) {
      @temp_conf = Tempfile.new('dnsmasq')
      @temp_enter_hook = Tempfile.new('dnsmasq')
      @temp_resolv_conf = Tempfile.new('dnsmasq')
    }

    after(:all) {
      @temp_conf.unlink
      @temp_enter_hook.unlink
      @temp_resolv_conf.unlink
    }

    subject {
      d = VCAP::Micro::Dnsmasq.new('foobar.com', '192.168.0.2')

      d.class.stub(:restart)

      d.conf_path = @temp_conf.path
      d.enter_hook_path = @temp_enter_hook.path
      d.resolv_conf_path = @temp_resolv_conf.path

      d
    }

    it 'should write the conf file' do
      subject.class.should_receive(:restart)

      subject.write
      @temp_conf.flush
      open(@temp_conf.path) { |f| f.read }
        .should == 'address=/foobar.com/192.168.0.2'
    end

    it 'should write the enter_hook file' do
      subject.class.should_receive(:restart)

      subject.write
      @temp_enter_hook.flush
      open(@temp_enter_hook.path) { |f| f.read }
        .should == <<-eos
if [ "$reason" = "BOUND" ]; then
  echo "address=/foobar.com/$new_ip_address" > /etc/dnsmasq.conf

  for ns in $new_domain_name_servers
  do
    if [ -e "/var/vcap/micro/offline" ]; then
      echo "# server=$ns"
    else
      echo "server=$ns"
    fi
  done > /etc/dnsmasq.d/server

  service dnsmasq restart
fi
eos
    end

    it 'should write the resolv.conf file' do
      subject.class.should_receive(:restart)

      subject.write
      @temp_resolv_conf.flush
      open(@temp_resolv_conf.path) { |f| f.read }
        .should == <<-eos
make_resolv_conf() {
  echo 'nameserver 127.0.0.1' > /etc/resolv.conf
}
eos
    end

  end

end
