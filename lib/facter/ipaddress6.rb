Facter.add(:ipaddress6, :timeout => 2) do
    setcode do
        require 'resolv'

        begin
            if hostname = Facter.value(:hostname)
                ip = Resolv.getaddresses(hostname)
                unless ip == "::1" or ip !=~ /(?>[0-9,a-f,A-F]+\:{0,2})+/
                    ip
                end
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

Facter.add(:ipaddress6, :timeout => 2) do
    setcode do
        if hostname = Facter.value(:hostname)
            # we need Hostname to exist for this to work
            host = nil
            if host = Facter::Util::Resolution.exec("host #{hostname}")
                host = host.chomp.split(/\s/)
                if defined? list[-1] and
                        list[-1] =~ /(?>[0-9,a-f,A-F]+\:{0,2})+/
                    list[-1]
                end
            else
                nil
            end
        else
            nil
        end
    end
end

Facter.add(:ipaddress6) do
    confine :kernel => :linux
    setcode do
        ip = nil
        output = %x{/sbin/ifconfig}

        output.scan(/inet6 addr: ((?>[0-9,a-f,A-F]*\:{0,2})+)/).each { |str|
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

       output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{0,2})+)/).each { |str|
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

       output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{0,2})+)/).each { |str|
                unless str =~ /fe80\:/ or str =~ /\:\:1/
                    ip = str
                end
        }

        ip
    end
end
