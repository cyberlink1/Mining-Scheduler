#!/usr/bin/perl
#


############################################################
#                                                          #
#     mining-scheduler_exporter_plugin for no-stats        #
#            V0.9 Written by cl@xganon.com                 #
#                      09/02/2020                          #
#                                                          #
############################################################


package none;

sub mstats() {
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
#Pull what we are mining
#

open my $file, '<', "/opt/mining-scheduler/run/miner" || die "Couldn't open $file: $!";
$mining = <$file>;
chomp($mining);
close $file;

  return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;
