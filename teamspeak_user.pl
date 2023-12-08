#!/usr/bin/perl -w
# teamspeak_user.pl
# Munin Plugin for Teamspeak3 Servers
# displays the number of connected users on TS3 servers

#######################################################
#
# by Tim Wulkau - www.wulkau.de
#
# 31.01.10 - v0.2
#            -fixed multiserver support
#            -corrected usercount
# 17.01.10 - v0.1
#            -initial release
#
######################################################

use strict;
use Net::Telnet;

# CONFIG HERE!
my $hostname = "localhost";    # serveraddress
my $port = 10011;              # querryport (default: 10011)
my @serverids = (1);           # array of virtualserverids (1,2,3,4,...) 

# SCRIPT START!
if(exists $ARGV[0] and $ARGV[0] eq "config")
{
  print "graph_title Teamspeak User\n";
  print "graph_vlabel Connected Teamspeak Users\n";
  print "graph_category Teamspeak\n";
  print "graph_info This graph shows the number of connected users on a Teamspeak3 server\n";
  foreach my $server (@serverids)
  {
    print "$server.label Users on Serverid $server\n";
    print "$server.type GAUGE\n";
    #print "$server.draw AREA\n";
  }
  exit 0;
}
else
{                              
  my $telnet = new Net::Telnet(Timeout=>5, Errmode=>"return", Prompt=>"/\r/"); 
  if ($telnet->open(Host=>$hostname, Port=>$port) != 1) {
    die exit;
  }     
  $telnet->waitfor("/TS3/"); 
  foreach my $server (@serverids)
  {
    $telnet->cmd("use sid=$server");
    $telnet->waitfor("/error id=0 msg=ok/");
    $telnet->cmd("serverinfo");
    
    my $line = $telnet->getline(Timeout=>5);
    if ($line =~ m/virtualserver_clientsonline=(\d+) /) {
      print "$server.value ".($1-1)."\n";
    }
    else {
      print "$server.value 0\n";
    }
    $telnet->waitfor("/error id=0 msg=ok/");
  }  
  $telnet->close;
}
exit;
