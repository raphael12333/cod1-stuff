#!/bin/bash
# The main logic of ServerArk, all done with iptables!
# Version 1.01
# (C) 2012 Boyd G. Gafford Ph.D. (Usage is under the LGPL)
# To contact me, simply post on the forum at elitewarriors.net.
#
# Please note these rules ONLY affect UDP packets to the game servers, nothing else!
# This script will protect all Q3-protocol servers on the port 28960.  It protects
# against both 'getstatus' and 'getinfo' attacks, as well as 'getchallenge' atttacks,
# even from a UDP flood with random source IPs.

#DELETE RULES TEMPORARILY
sudo iptables --flush

# Add a limit/drop chain for "getstatus" packets that limits it to 10 a second for all servers.
# If you are only protecting one server, you can set the number from 10 down to 4 (or 2 even).
sudo iptables -N LIMITSTAT
sudo iptables -A LIMITSTAT -p udp -m limit --limit 10/sec --limit-burst 10 -j ACCEPT
sudo iptables -A LIMITSTAT -p udp -j DROP

# Add a limit/drop chain for "getinfo" packets that limits it to 10 a second for all servers.
# If you are only protecting one server, you can set the number from 10 down to 4 (or 2 even).
sudo iptables -N LIMITINFO
sudo iptables -A LIMITINFO -p udp -m limit --limit 10/sec --limit-burst 10 -j ACCEPT
sudo iptables -A LIMITINFO -p udp -j DROP

# Add a limit/drop chain for "getchallenge" packets that limits it to 5 a second for all servers.
# If you are only protecting one server, you can set the number from 5 down to 2.  Setting it
# at 2 means only 2 players could connect to the server per second.  Set LIMITCONN to the
# same, as there is one getchallenge/connect packet sequence per valid player connection.
sudo iptables -N LIMITCHLG
sudo iptables -A LIMITCHLG -p udp -m limit --limit 5/sec --limit-burst 5 -j ACCEPT
sudo iptables -A LIMITCHLG -p udp -j DROP

# Add a limit/drop chain for "connect" packets that limits it to 5 a second for all servers.
# If you are only protecting one server, you can set the number from 5 down to 2.  Setting it
# at 2 means only 2 players could connect to the server per second.  Set LIMITCHLG to the
# same, as there is one getchallenge/connect packet sequence per valid player connection.
sudo iptables -N LIMITCONN
sudo iptables -A LIMITCONN -p udp -m limit --limit 5/sec --limit-burst 5 -j ACCEPT
sudo iptables -A LIMITCONN -p udp -j DROP

# Add a limit chain that prevents more than 70 packets a second per player.
# This is the main logic of ServerArk, but just performed by an iptable rule.
# We allow up to 128 players which is enough for 4 servers full (at 32 players each).
# If you only have one server, you could the size and max to 32.
# If you have players who have manually set their packet rate up to 100, just change the 70 to 100.
sudo iptables -N LIMITPLRS
sudo iptables -A LIMITPLRS -p udp -m hashlimit --hashlimit-name PLAYERS --hashlimit-above 125/sec --hashlimit-burst 125 --hashlimit-mode srcip,srcport --hashlimit-htable-size 128 --hashlimit-htable-max 128 --hashlimit-htable-gcinterval 1000 --hashlimit-htable-expire 10000 -j DROP
sudo iptables -A LIMITPLRS -p udp -j ACCEPT

# Add the rules to pick out the various special packets and send them to appropriate limit chains.
# To protect 5 ports, just specify a range like "--dport 28960:28964" below.
sudo iptables -A INPUT -p udp --dport 28960:28964 -m string --string "getstatus" --algo bm --from 32 --to 33 -j LIMITSTAT
sudo iptables -A INPUT -p udp --dport 28960:28964 -m string --string "getinfo" --algo bm --from 32 --to 33 -j LIMITINFO
sudo iptables -A INPUT -p udp --dport 28960:28964 -m string --string "getchallenge" --algo bm --from 32 --to 33 -j LIMITCHLG
sudo iptables -A INPUT -p udp --dport 28960:28964 -m string --string "connect" --algo bm --from 32 --to 33 -j LIMITCONN

# Send all other packets (normal player packets) to the limit players chain.
# A port range like "--dport 28960:28964" could also be used here as well.
sudo iptables -A INPUT -p udp --dport 28960:28964 -j LIMITPLRS
