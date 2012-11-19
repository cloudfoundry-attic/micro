require 'tempfile'

require 'micro/dnsmasq'

describe VCAP::Micro::Dnsmasq do

  subject {
    VCAP::Micro::Dnsmasq.new(
      :domain => 'foobar.com',
      :ip => '192.168.0.2',
      :upstream_servers => %w{1.2.3.4}
    )
  }

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

  its(:gen_upstream_servers) { should ==  <<-eos
server=1.2.3.4
eos
  }

  describe '#write' do

    before(:all) {
      @temp_conf = Tempfile.new('dnsmasq')
      @temp_enter_hook = Tempfile.new('dnsmasq')
      @temp_resolv_conf = Tempfile.new('dnsmasq')
      @temp_upstream_servers = Tempfile.new('dnsmasq')
    }

    after(:all) {
      @temp_conf.unlink
      @temp_enter_hook.unlink
      @temp_resolv_conf.unlink
      @temp_upstream_servers.unlink
    }

    subject {
      d = VCAP::Micro::Dnsmasq.new(
        :domain => 'foobar.com',
        :ip => '192.168.0.2',
        :upstream_servers => %w{1.2.3.4},

        :conf_path => @temp_conf.path,
        :enter_hook_path => @temp_enter_hook.path,
        :resolv_conf_path => @temp_resolv_conf.path,
        :upstream_servers_path => @temp_upstream_servers.path
      )

      d.class.stub(:restart)

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

    it 'should write the upstream servers file' do
      subject.class.should_receive(:restart)

      subject.write
      @temp_upstream_servers.flush
      open(@temp_upstream_servers.path) { |f| f.read }
        .should == <<-eos
server=1.2.3.4
eos
    end

  end

  describe '#read' do

    subject {
      temp_conf = Tempfile.new('dnsmasq')
      temp_upstream_servers = Tempfile.new('dnsmasq')

      temp_conf.write("address=/foobar.com/192.168.0.2\n")
      temp_conf.flush

      temp_upstream_servers.write("server=1.2.3.4\n")
      temp_upstream_servers.flush

      d = VCAP::Micro::Dnsmasq.new(
        :conf_path => temp_conf.path,
        :upstream_servers_path => temp_upstream_servers.path
      ).read

      temp_conf.unlink
      temp_upstream_servers.unlink

      d
    }

    its(:domain) { should == 'foobar.com' }
    its(:ip) { should == '192.168.0.2' }
    its(:upstream_servers) { should == %w{1.2.3.4} }
  end

end
