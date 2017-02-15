require 'socket'

loopback = '127.0.0.1'

ipv4_private_addrs = Socket.ip_address_list.find_all { |intf| intf.ipv4_private? }
if !ipv4_private_addrs.empty?
  ENV['ipv4_private'] = ipv4_private_addrs.last.ip_address
else
  ENV['ipv4_private'] = loopback
end

ipv4_public_addrs = Socket.ip_address_list.find_all { |intf| intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? && !intf.ipv4_private?}
if !ipv4_public_addrs.empty?
  ENV['ipv4_public'] = ipv4_public_addrs.last.ip_address
else
  ENV['ipv4_public'] = loopback
end
