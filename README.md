**mining-scheduler**

mining-scheduler is a simple script designed to let you start/stop/rotate crypto mining software and to start the mining software if the system reboots. Using the Linux crontab it lets you schedule out when you want it to start or stop and when you want it to rotate to the next miner in the list.

**Use Case (Why I wrote it)**
I have a small mining rig I wanted to use to mine low cap crypto currency. However, I really wanted it to mine a coin for a week then switch to the next coin and mine it for a week. I could do this by hand but prefer it to be automated and with auto payouts from the mining pools it will do it all from mining a coin for a week to depositing the coins in my wallet. 

Thus the mining-scheduler was born. I run it from cron and it does the rest.

**Alternate use case #1**
 An alternate use case is to set it up with a cronjob to start and stop the miner. For example you could have your system mine coins while you are at work (8-5) my setting a cronjob to run with the -b (start/boot) option at 8am and the -q (stop/quit) option at 5pm. Thus autostarting and stopping your miner. You could even add a cronjob to do the -r (rotate) every Sunday at midnight or on the first of every month.

**Alternate use case #2 suggested by jagerhund101 of Reddit**
It can be used to turn off mining during peak electricity hours. You can set the time as well as the days of the week and months that are affected by the peak electricity billing. See the bottom of this file for an example.

**How it works**

The miners.cfg file contains a list of coins you wish to mine along with the directory location of the miner and the command line to start the miner.

The scheduler.cfg file contains the setting for the home directory of the mining-scheduler script. You can also add any environment variables you need for the miner (Ex: AMD Environment). The scheduler.cfg is sourced at the start of the script, this means that you can also add any command lines you need to execute before the scrip starts such as one that sets the overclock of gpu or memory.

**Directories**

```
   $HOME/run     Used by the script to store a tmp file that contains the name of the running miner
   $HOME/pid     Used by the script to store a tmp file with the pid of the running miner
   $HOME/log     When the script starts a miner, STDOUT is redirected to a log file in this directory. The log file name is the <miner_name>.log
   $HOME/miners  I put all my miners in this directory. The script does not require it as we will discuss later. It is just a good way of keeping the system clean and organized.
```


**miners.cfg file**
  This config file is broken down into a colon separated list of miners with one miner per line. Any line that starts with a # is considered a comment.

  The line format is as follows
   `<Miner_Name>:<Miner_home_directory>:<Miner_commandline>`

   Restrictions and limitations.
```
   <Miner_Name>            must be a single word or string with no spaces and no colons! 
   <miner_home_directory>  Can not have any spaces. If the directory starts with a / then it is considered an absolute path. If it does not start with a / it is considered to be relitive to the $MHOME directory set in scheduler.cfg
   <Miner_commandline>     This is the command line to start the miner. If the miner offers a "daemon" mode or a "background" mode please do not use those options. The script takes care of starting the process in the background.
```

**mining-scheduler.service**
   This is a systemd service file to start the mining-service at boot. This way if your system reboots, mining-scheduler will restart the miner that it was working with. The install.sh will set this file up and copy it to the /usr/lib/systemd/system/ directory and load it into systemd. After which you can use the systemctl command to start, and stop the process as well as enable it at boot.

**Options and Usage**

        Usage: mining-scheduler <OPTION>
        -b             # used when booting up or when you want to restart the miner
        -s <miner>     # starts a given miner
        -r             # rotates to the next miner
        -c             # clears the system run and pid files
        -q             # Quit/stop running miner
        -u 1/0         # User Halt 1=on Stops miner and blocks it from starting at boot. 0=off
        -h             # This help file

**More Details**
 
   The "-b" option is used when the system boots or when you want to start the miner running. If no miner was previously running it will take the first miner in the list and start it. If a previous miner was running, but the miner is not currently running, it will start the miner. If a miner is already running it will exit telling you that the miner is running.

   The "-s <miner>" option takes the name of the miner you specified and starts it running. If a miner is currently running, it will tell you to run the -q option first to stop the miner.

   The "-r" option stops the current miner that is running and starts the next miner in the miners.cfg file.

   The "-c" option clears the run and pid files. If you do this before stopping the running miner, mining-scheduler will tell you to run the -q option first. This resets the mining-scheduler so the next run will be the first miner in the list or the miner you specified with a -s option.

   The "-q" option stops the miner that is currently running but remembers what it was, so running with the "-b" option will start back where it left off.
   
   The "-u" option sets a HALT condition. If it is on (1=on) then the miner will be stopped and it will not start until the condition is removed by clearing the option (0=off) When you clear the option it will auto start the miner. This was implemented for those that want to halt the miner during peak hours. If the system reboots the miner will not start back up until the Halt state is cleared.

*NOTE: mining-scheduler only accepts one `<OPTION>` at a time. This means that you CAN NOT do a "mining-script -q -s next_miner" as it will only take the -q option and ignore anything after that.*


**Cron Job examples**

For those not familiar with crontabs in Linux it breaks down as follows (each star is a field, edit with "crontab -e")

`* * * * * <command>`

      The time and date fields are:

              field          allowed values
              -----          --------------
              minute         0-59
              hour           0-23
              day of month   1-31
              month          1-12 (or names, see below)
              day of week    0-7 (0 or 7 is Sunday, or use names)

So to rotate miners every Sunday at 23:59 you would edit the crontab and enter

59 23 * * 7 /directory/where/scheduler/is/mining-scheduler -r

To rotate miners at 01:05 (am) on the first of the month you would enter

05 01 1 * * /directory/where/scheduler/is/mining-scheduler -r

To start the miner at 8:00 and stop it at 17:00 you would enter

00 08 * * * /directory/where/scheduler/is/mining-scheduler -b

00 17 * * * /directory/where/scheduler/is/mining-scheduler -q

Peak hours where I am are 1pm to 7pm Monday through Friday for the months of June to September. To stop the miner during peak hours and start it for off peak hours you would use the following two cron entries.

00 13 * 6-9 1-5 /directory/where/scheduler/is/mining-scheduler -u 1

00 19 * 6-9 1-5 /directory/where/scheduler/is/mining-scheduler -u 0


**Miner Notes from my testing**

* ethminer needs the --stdout option to work with this script.  (https://github.com/ethereum-mining/ethminer/releases)
* teamredminer works with no issues  (https://github.com/todxx/teamredminer/releases)
* lolminer works with no issues (https://github.com/Lolliedieb/lolMiner-releases)
* Claymore miner works. (https://github.com/Claymore-Dual/Claymore-Dual-Miner/releases)
* xmrig miner works (https://github.com/xmrig/xmrig/releases)
* nsgminer needs the --text-only option to work with the script (https://github.com/ghostlander/nsgminer) You have to compile the source for linux.
* PhoenixMiner work (https://mega.nz/#F!2VskDJrI!lsQsz1CdDe8x5cH3L8QaBw)

*I have not tested other miners but will update the list as I test them, or if others report a working status*
