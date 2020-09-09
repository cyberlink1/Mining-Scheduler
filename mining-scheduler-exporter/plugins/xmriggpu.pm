#!/usr/bin/perl
#


############################################################
#                                                          #
#   mining-scheduler_exporter_plugin for XMRig Miner       #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################


package xmriggpu;

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
my $url = 'http://localhost:4028';

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
  $pool = $stats->{'connection'}{'pool'};
  $user = $stats->{'worker_id'};
  $miner = $stats->{'version'};
  $total_watts = 0;
  $total_hashrate = $stats->{'hashrate'}{'total'}[0];
  $total_shares_accepted = $stats->{'results'}{'shares_good'};
  $total_shares_submitted = $stats->{'results'}{'shares_total'};
  @GPUS=$stats->{'hashrate'}{'threads'};
  my $I = 0;
  foreach my $outer (@GPUS) { 
    foreach my $inner (@$outer) {
    foreach my $element (@$inner) {
        @gpu_hashrate[$I] = $element;
	  @gpu_temp[$I] = 0;
	  @gpu_fanspeed[$I] = 0;
	  @gpu_watts[$I] = 0;
	  @gpu_shares_accepted[$I] = 0;
          @gpu_shares_submitted[$I] = 0;

    }
    $I++;
  }
  }
  $miner="XMRig $miner";
  return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;
