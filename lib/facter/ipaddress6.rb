# Uses ruby's own resolv class which queries DNS and /etc/hosts.
# The closest thing to a default/primary IPv6 addresses is
# assumed to be the AAAA that you have published via DNS or
# an /etc/host entry.
Facter.add(:ipaddress6, :timeout => 2) do
  setcode do
    require 'resolv'

    begin
      if hostname = Facter.value(:hostname)
        Resolv.getaddresses(hostname).each { |str|
          if str =~ /(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}/ and !~ /\:\:1/
            ip = str
          end
        }

      ip

      else
        nil
      end
      rescue Resolv::ResolvError
        nil
      rescue NoMethodError # i think this is a bug in resolv.rb?
        nil
    end
  end
end

# Uses the OS' host command to do a DNS lookup.
Facter.add(:ipaddress6, :timeout => 2) do
  setcode do
  if hostname = Facter.value(:hostname)
    # we need Hostname to exist for this to work
    host = nil
    if host = Facter::Util::Resolution.exec("host -t AAAA #{hostname}")
      host.scan(/((?>[0-9,a-f,A-F]{0,4}\:{1,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      unless str =~ /fe80\:/ or str =~ /\:\:1/
       ip = str
      end
    }
    else
      nil
    end
    ip
  else
    nil
  end
  end
end

# OS dependant code that parses the output of various networking
# tools and currently not very intelligent. Returns the first
# non-loopback and non-linklocal address found in the ouput. Most
# code ported or modeled after the ipaddress fact for the sake of
# similar functionality and familiar mechanics.
Facter.add(:ipaddress6) do
  confine :kernel => :linux
  setcode do
    ip = nil
    output = %x{/sbin/ifconfig}

    output.scan(/inet6 addr: ((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      unless str =~ /fe80\:/ or str =~ /\:\:1/
        ip = str
      end
    }

    ip

  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{SunOS}
  setcode do
    ip = nil
    output = %x{/usr/sbin/ifconfig -a}

    output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{0,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      unless str =~ /fe80\:/ or str =~ /\:\:1/
        ip = str
      end
    }

    ip

  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{Darwin}
  setcode do
    ip = nil
    output = %x{/sbin/ifconfig -a}

    output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      unless str =~ /fe80\:/ or str =~ /\:\:1/
        ip = str
      end
      }

      ip

  end
end

