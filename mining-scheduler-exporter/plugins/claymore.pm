#!/usr/bin/perl

############################################################
#                                                          #
#  mining-scheduler_exporter_plugin for Claymore Miner     #
#           V0.9 Written by cl@xganon.com                  #
#                     09/02/2020                           #
#                                                          #
############################################################

package phoenixminer;

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
# need to break the below off into a pm file and have it return ($var, $var, $var, \@array, etc.)
#

#
# URL to pull JSON data from miner
#
my $url = "127.0.0.1:3333";

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
#  my $content = get $url;
#  die "Couldn't get $url" unless defined $content;
#
$| = 1;

my ($socket,$data);

$socket = new IO::Socket::INET ( 
	PeerAddr   => $url, 
	Proto      => 'tcp'
        ) or die "ERROR in Socket Creation : $!\n";
#send operation
$data = "{\"id\":0,\"jsonrpc\":2.0,\"method\":\"miner_getstat1\"}\n";
$socket->send($data);
$data = <$socket>;
$socket->close();

#
# Decode the JSON Data and place into vars
#
  $stats = decode_json $data;
  my ($hr, $sh, $rj)=split(";", $stats->{'result'}[2]);
  $total_shares_submitted = $sh;
  $total_hashrate = $hr;
  $total_shares_accepted = $sh-$rj;
  $total_watts = "0";
  $miner= $stats->{'result'}[0];
  $pool = $stats->{'result'}[7];
  $user = "Unkown";
  @temp = split(";", $stats->{'result'}[6]);
  @hash = split(";", $stats->{'result'}[3]);
  $GPUS = scalar @temp-1;
  $GPU=0;
  for (my $i = 0; $i <= $GPUS; $i+=2 ){
          @gpu_temp[$GPU] = @temp[$i];
          @gpu_fanspeed[$GPU] = @temp[$i+1];
          $GPU++;
  }
  $GPUS = scalar @hash-1;
  print "GPUS : $GPUS\n";
  for (my $i = 0; $i <= $GPUS; $i++ ){
          print "i=$i\n";
          @gpu_hashrate[$i] = @hash[$i];
          @gpu_watts[$i] = "0";
          @gpu_shares_accepted[$i] = "0";
          @gpu_shares_submitted[$i] = "0";
  }

    return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted);
}
1;
