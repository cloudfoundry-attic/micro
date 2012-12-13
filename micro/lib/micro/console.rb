require 'logger'

require 'micro/network'
require 'micro/identity'
require 'micro/agent'
require 'micro/settings'
require 'micro/watcher'
require 'micro/version'
require 'micro/memory'
require 'micro/proxy'
require 'micro/core_ext'
require 'micro/dns'
require 'micro/service_manager'

module VCAP
  module Micro
    class Console
      extend Forwardable
      def_delegators :@high_line, :agree, :ask, :choose, :say

      def self.run
        Console.new.console
      end

      CC_CONFIG = "/var/vcap/jobs/cloud_controller/config/cloud_controller.yml".freeze
      SBTA = "/var/vcap/micro/SBTA".freeze
      LOGFILE = "/var/vcap/sys/log/micro/micro.log".freeze

      def self.logger
        logfile = ENV['LOGFILE'] ? ENV['LOGFILE'] : LOGFILE
        FileUtils.mkdir_p(File.dirname(logfile))
        unless defined? @@logger
          @@logger = Logger.new(logfile, 5, 1024*100)
          @@logger.level = Logger::INFO
        end
        @@logger
      end

      def initialize(input = $stdin, output = $stdout)
        @run = true
        @high_line = HighLine.new(input, output)
        @logger = Console.logger
        @proxy = Proxy.new
        @identity = Identity.new(@proxy)
        @network = Network.new
        @memory = Memory.new
        @watcher = Watcher.new(@network, @identity)
        @svcmgr = ServiceManager.new
        @watcher.start
      end

      def console
        VCAP::Micro::Agent.start if @identity.configured?
        # TODO add a timeout so the console will be auto-refreshed
        while @run
          clear
          say "Welcome to VMware Micro Cloud Foundry version #{VCAP::Micro::Version::VERSION}\n\n"
          say "To configure go to http://#{Network.local_ip}:9292/ in your browser.\n\n"
          status
          menu
        end
      rescue => e
        clear
        @logger.error("caught exception: #{e.message}\n#{e.backtrace.join("\n")}")
        say "Oh no, an uncaught exception: #{e.message}\n\n"
        say(e.backtrace.first(15).join("\n")) if @logger.level == Logger::DEBUG
        #retry instead of restart?
        say "\npress any key to restart the console"
        STDIN.getc
      end

      def configure_network(initial=false)
        say "\n"
        choose do |menu|
          menu.prompt = "Select network: "
          menu.choice("DHCP") do
            @network.dhcp
          end
          menu.choice("Static") do
            net = Hash.new
            say("\nEnter network configuration (address/netmask/gateway/DNS)")

            # make sure we get a String not a HighLine::String
            net['address'] = ask("Address: ").to_s
            net['netmask'] = ask("Netmask: ").to_s
            net['gateway'] = ask("Gateway: ").to_s
            net['dns'] =     ask("DNS:     ").to_s
            # TODO validate network
            @network.static(net)
            DNS.new(net['address'], @identity.subdomain).generate
          end
        end
        press_return_to_continue unless initial
      end

      def restart
        @network.restart
        press_return_to_continue
      end

      def display_help
        clear
        File.open("/var/vcap/micro/banner") do |file|
          file.readlines.each { |line| puts line }
        end

        press_return_to_continue
      end

      def network_troubleshooting
        clear
        say("Network troubleshooting\n".yellow)

        unless @identity.configured?
          say("Please configure Micro Cloud Foundry first...")
          return
        end

        # get IP
        ip = Network.local_ip
        ip_address = ip.to_s.green
        say("VM IP address is: #{ip_address}")
        say("configured IP address is: #{@identity.ip.green}")

        # get router IP
        gw = Network.gateway
        gateway = gw.to_s.green
        say("gateway IP address is: #{gateway}")

        # ping router IP
        ping = if Network.ping(gw, 1)
          "yes".green
        else
          "no".red
        end
        say("can ping gateway: #{ping}")

        say("configured domain: #{@identity.subdomain.green}")
        say("reverse lookup of IP address: #{Network.lookup(ip).to_s.green}")

        if @network.online?
          # DNS lookup
          url = @identity.subdomain
          ip = Network.lookup(url)
          say("DNS lookup of #{url} is #{ip.to_s.green}")

          # proxy
          say("proxy is #{@proxy.name.green}")
          say("configured proxy is #{RestClient.proxy}\n")

          # get URL (through proxy)
          url = "www.cloudfoundry.com"
          rest = RestClient::Resource.new("http://#{url}")
          rest["/"].get
          say("successfully got URL: #{url.green}")
        else
          puts "in offline mode - skipping DNS and remote connections"
        end

      rescue RestClient::Exception => e
        say("\nfailed to get URL: #{e.message}".red)
      rescue => e
        say("exception: #{e.message}".red)
        @logger.error(e.backtrace.join("\n"))
      end

      def quit
        @run = false
      end

      private

      def menu
        choose do |menu|
          menu.select_by = :index
          menu.prompt = "\nSelect option: "
          menu.choice("Reconfigure network") { configure_network }
          menu.choice("Restart network") { restart }
          menu.choice("Troubleshoot network") { network_troubleshooting }
          menu.choice("Help") { display_help }
          menu.hidden("Quit") { quit }
        end
      end

      def status
        if @identity.api_host != Identity::DEFAULT_API_HOST
          say("Using API host: #{@identity.api_host}\n".yellow)
        end

        if @identity.configured?
          say("Current Configuration:")
          say(" Identity:   #{@identity.subdomain} (#{dns_status})")
          admins = @identity.admins.nil? ? "none" : @identity.admins.join(', ')
          say(" Admin:      #{admins}")
          current = (ip = Network.local_ip) != @identity.ip ? " (actual #{ip})" : ""
          say(" IP Address: #{@identity.ip} (network #{network_status})#{current}\n\n")
          say("To access your Micro Cloud Foundry instance, use:")
          say("vmc target http://api.#{@identity.subdomain}\n\n")
        end
      end

      def network_status
        stat = @network.status.to_s
        case @network.status
          when :up
            stat.green
          when :failed
            stat.red
          else
            stat.yellow
        end
        stat += " / #{@network.online_status}" unless @network.online?
        stat
      end

      def dns_status
        if !@network.online? # dont't warn when offline
          "ok".green
        elsif @identity.ip != VCAP::Micro::Network.local_ip
          "DNS out of sync".red
        else
          "ok".green
        end
      end

      def clear
        say "\e[H\e[2J"
      end

      def configured?
        File.exist?(CC_CONFIG)
      end

      def press_return_to_continue
        ask("Press return to continue ")
      end
    end
  end
end
