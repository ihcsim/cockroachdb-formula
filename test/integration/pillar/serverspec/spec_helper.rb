require 'socket'

ipv4_private = Socket.ip_address_list.detect{ |intf| intf.ipv4_private? }
ENV['ipv4_private'] = ipv4_private.ip_address

ipv4_public = Socket.ip_address_list.detect{ |intf| intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? && !intf.ipv4_private?}
ENV['ipv4_public'] = ipv4_public.ip_address
