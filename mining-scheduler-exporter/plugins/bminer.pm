#!/usr/bin/perl
#


############################################################
#                                                          #
#      mining-scheduler_exporter_plugin for BMiner         #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################


package bminer;

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
# need to break the below off into a pm file and have it return ($var, $var, $var, \@array, etc.)
#

#
# URL to pull JSON data from miner
#
my $url1 = 'http://localhost:1880/api/v1/status/solver';
my $url2 = 'http://localhost:1880/api/v1/status/device';
my $url3 = 'http://localhost:1880/api/v1/status/stratum';

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
  my $content = get $url1;
  die "Couldn't get $url1" unless defined $content;

#
# Decode the JSON Data and place into vars
#
  $stats = decode_json $content;
#
#
#  Count the Solvers to identify how many GPU's
#
  my $I = 0;
  my $solvers="start";
  while ($solvers) {
       $solvers = $stats->{'devices'}{$I}{'solvers'}[0]{'algorithm'};
       $I++;
  }

#
# Now lets walk throug them to identify the algorithm as well as set the hashrate for the cards
#
  $GPUS=$I-2;
  for ( my $i = 0; $i <= $GPUS; $i++ ) {
       @gpu_hashrate[$i] = $stats -> {'devices'}{$i}{'solvers'}[0]{'speed_info'}{'hash_rate'};
       $solvers = $stats->{'devices'}{$i}{'solvers'}[0]{'algorithm'};
  }

#
# Pull the JSON data for devices into $content var
#
  my $content = get $url2;
  die "Couldn't get $url2" unless defined $content;

#
# Decode the JSON Data for devices and place into vars
#
  $stats = decode_json $content;

  for (my $i = 0; $i <= $GPUS; $i++){
          @gpu_temp[$i] = $stats -> {'devices'}{$i}{'temperature'};
          @gpu_fanspeed[$i] = $stats -> {'devices'}{$i}{'fan_speed'};
          @gpu_watts[$i] = $stats -> {'devices'}{$i}{'power'};
          @gpu_shares_accepted[$i] = 0;
          @gpu_shares_submitted[$i] = 0;
  }


#
# Pull the JSON data for stratum into $content var
#
  my $content = get $url3;
  die "Couldn't get $url3" unless defined $content;

#
# Decode the JSON Data for devices and place into vars
#
  $stats = decode_json $content;

  $pool = $stats->{'stratums'}{$solvers}{'failover_uris'}[0]{'name'};
  $user = $stats->{'stratums'}{$solvers}{'failover_uris'}[0]{'name'};
  $miner = "Bminer";
  $total_shares_accepted = $stats->{'stratums'}{$solvers}{'accepted_shares'};
  $total_shares_submitted = $stats->{'stratums'}{$solvers}{'accepted_shares'}+$stats->{'stratums'}{'ethash'}{'rejected_shares'};
 
 for (my $i = 0; $i <= $GPUS; $i++){
  $total_watts = $total_watts+@gpu_watts[$i];
  $total_hashrate = $total_hashrate+@gpu_hashrate[$i];
 }

  return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;
