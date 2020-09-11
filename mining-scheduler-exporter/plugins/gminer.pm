#!/usr/bin/perl
#
############################################################
#                                                          #
#      mining-scheduler_exporter_plugin for GMiner         #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################


package gminer;

sub mstats() {
use JSON;
use LWP::Simple;
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

#
# URL to pull JSON data from miner
#
my $url = 'http://localhost:4028/stat';

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
  my $content = get $url;
  print "Couldn't get $url" unless defined $content;

#
# Decode the JSON Data and place into vars
#
  $stats = decode_json $content;
  $pool = $stats->{'Server'};
  $user = $stats->{'user'};
  $miner = $stats->{'miner'};
  $total_watts = 0;
  $total_hashrate = $stats->{'Session'}{'Performance_Summary'};
  $total_shares_accepted = $stats->{'tota_accepted_shares'};
  $total_shares_submitted = $stats->{'tota_accepted_shares'}+$stats->{'tota_rejected_shares'};
  $GPUS=scalar $stats->{'devices'};
  #
  #Pull GPU Data and output
  #
  print "$GPUS";
  $GPUS=$GPUS-1;
  for (my $i = 0; $i <= $GPUS; $i++){
	  @gpu_temp[$i] = $stats -> {'GPUs'}[$i]{'Temps (deg C)'};
	  @gpu_fanspeed[$i] = $stats -> {'GPUs'}[$i]{'Fan Speed (%)'};
	  @gpu_watts[$i] = $stats -> {'GPUs'}[$i]{'Consumption (W)'};
	  @gpu_hashrate[$i] = $stats -> {'GPUs'}[$i]{'Performance'};
	  @gpu_shares_accepted[$i] = $stats -> {'GPUs'}[$i]{'Session_Accepted'};
          @gpu_shares_submitted[$i] = $stats -> {'GPUs'}[$i]{'Session_Submitted'};
  }
  return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;
