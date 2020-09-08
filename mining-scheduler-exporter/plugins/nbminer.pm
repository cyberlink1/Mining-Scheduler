#!/usr/bin/perl
#


############################################################
#                                                          #
#     mining-scheduler_exporter_plugin for NBMiner         #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################


package nbminer;

sub mstats() {
use JSON;
use LWP::Simple;
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

#
# need to break the below off into a pm file and have it return ($var, $var, $var, \@array, etc.)
#

#
# URL to pull JSON data from miner
#
my $url = 'http://localhost:4028/api/v1/status';

#
#Pull what we are mining
#

open my $file, '<', "/opt/mining-scheduler/run/miner" || die "Couldn't open $file: $!";
$mining = <$file>;
chomp($mining);
close $file;

#
# Pull the JSON data into $content var
#
  my $content = get $url;
  die "Couldn't get $url" unless defined $content;

#
# Decode the JSON Data and place into vars
#
  $stats = decode_json $content;
  $pool = $stats->{'stratum'}{'url'};
  $user = $stats->{'stratum'}{'user'};
  $miner = "NBMiner $stats->{'version'}";
  $total_watts = $stats->{'miner'}{'devices'}[0]{'total_power_consume'};
  $total_hashrate = $stats->{'miner'}{'devices'}[0]{'total_hashrate_raw'};
  $total_shares_accepted = $stats->{'miner'}{'stratum'}{'accepted_shares'};
  $total_shares_submitted = $stats->{'miner'}{'stratum'}{'accepted_shares'}+$stats->{'miner'}{'stratum'}{'rejected_shares'};
  my @GPUS1=$stats->{'miner'}{'devices'};
  #
  #Pull GPU Data and output
  #
  $GPUS=scalar @GPUS1;
  for (my $i = 0; $i <= $GPUS; $i++){
	  @gpu_temp[$i] = $stats -> {'miner'}{'devices'}[$i]{'temperature'};
	  @gpu_fanspeed[$i] = $stats -> {'miner'}{'devices'}[$i]{'fan'};
	  @gpu_watts[$i] = $stats -> {'miner'}{'devices'}[$i]{'power'};
	  @gpu_hashrate[$i] = $stats -> {'miner'}{'devices'}[$i]{'hashrate_raw'};
	  @gpu_shares_accepted[$i] = $stats -> {'miner'}{'devices'}[$i]{'accepted_shares'};
          @gpu_shares_submitted[$i] = $stats -> {'miner'}{'devices'}[$i]{'accepted_shares'}+$stats -> {'miner'}{'devices'}[$i]{'rejected_shares'};
  }
  return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;

