#!/usr/bin/perl

############################################################
#                                                          #
#      mining-scheduler_exporter_plugin for nsgminer       #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################

package nsgminer;

sub mstats() {
use JSON;
use IO::Socket::INET;
use Data::Dumper;

#
# Variables for this plugin
#
my $pool;
my $user;
my $mining;
my $miner;
my @gpu_temp;
my @gpu_fanspeed;
my @gpu_watts;
my @gpu_hashrate;
my @gpu_shares_accepted;
my @gpu_shares_submitted;
my $total_watts;
my $total_hashrate;
my $total_shares_accepted;
my $total_shares_submitted; 
my $GPUS=0;
my $GPU=0;

#
# URL to pull JSON data from miner
#
my $url = "127.0.0.1:4028";

#
#Pull what we are mining
#

open my $file, '<', "/opt/mining-scheduler/run/miner" || print "Couldn't open $file: $!";
$mining = <$file>;
chomp($mining);
close $file;

#
# Pull the JSON data into $content var
#
#  my $content = get $url;
#  print "Couldn't get $url" unless defined $content;
#
$| = 1;

my ($socket,$data);

$socket = new IO::Socket::INET ( 
	PeerAddr   => $url, 
	Proto      => 'tcp'
        ) or print "ERROR in Socket Creation : $!\n";
#send operation
$data = "{\"command\":\"summary+devs\",\"parameter\":\"\"}\n";
$socket->send($data);
$data = <$socket>;
$socket->close();

#
# Decode the JSON Data and place into vars
#
  $stats = decode_json $data;
  
  $miner = $stats->{'summary'}{'STATUS'}[0]{'Description'};
  $total_shares_submitted = $stats->{'summary'}{'SUMMARY'}[0]{'Accepted'}-$stats->{'summary'}{'SUMMARY'}[0]{'Rejected'};
  $total_hashrate = $stats->{summary}{'SUMMARY'}[0]{'KHS av'}*1000;
  $total_shares_accepted = $stats->{'summary'}{'SUMMARY'}[0]{'Accepted'};
  $total_watts = "0";
  $pool = "No Data";
  $user = "No Data";

#send operation
  
  $GPUS = $stats->{'devs'}{'STATUS'}[0]{'Msg'};
  $GPUS =~ /^([0-9].).*/;
  $GPUS = $1;
  $GPU=0;
  for (my $i = 0; $i <= $GPUS-1; $i++ ){
          @gpu_temp[$i] = $stats->{'devs'}{'DEVS'}[$i]{'Temperature'};
          @gpu_fanspeed[$i] = $stats->{'devs'}{'DEVS'}[$i]{'Fan Percent'};
          @gpu_hashrate[$i] = $stats->{'devs'}{'DEVS'}[$i]{'KHS 30s'}*1000;
          @gpu_watts[$i] = "0";
          @gpu_shares_accepted[$i] = $stats->{'devs'}{'DEVS'}[$i]{'Accepted'};
          @gpu_shares_submitted[$i] = $stats->{'devs'}{'DEVS'}[$i]{'Accepted'}+$stats->{'devs'}{'DEVS'}[$i]{'Rejected'};
  }

    return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;

