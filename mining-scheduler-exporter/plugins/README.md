This is the directory for the miner exporter plugins.

 * Stats plugins are perl modules and must end in .pm
 * Stats plugins must be named all lowercase and must be the same name used to call them in the miners.cfg
 * Stats plugins must contain "package <plugin_name>;"
 * Stats plugins must have atlease one sub named "sub mstats()"
 * Stats plugins must return the following in order
   * pool
   * user
   * miner
   * total_watts
   * total_hashrate
   * total_shares_accepted
   * total_shares_submitted
   * pointer to an array of gpu_temp
   * pointer to an array of gpu_fanspeed
   * pointer to an array of gpu_watts
   * pointer to an array of gpu_hashrate
   * pointer to an array of gpu_shares_accepted
   * pointer to an array of gpu_shares_submitted

I use the following return line.

```
    return ($pool, $user, $miner, $total_watts, $total_hashrate, $total_shares_accepted, $total_shares_submitted, \@gpu_temp, \@gpu_fanspeed, \@gpu_watts, \@
gpu_hashrate, \@gpu_shares_accepted, \@gpu_shares_submitted)
```
