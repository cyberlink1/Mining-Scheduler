**I am using Ubuntu 20.04 (LTS) and have only tested it on this distribution and version of Linux!**

Login to your fresh install of Ubuntu 20.04 and run a git clone of this repo

git clone https://github.com/fixit/mining-scheduler.git

Once you have it downloaded, cd to the mining-scheduler directory and run the install.sh

cd mining-scheduler

./install.sh

Tell it where to install the mining scheduler, what user to run it as, if you want it to start at boot, etc. The install script will put everything in place for you.

You will find 2 scripts in the miner directory, one I use to download the standard miners I use and the other will build a copy of sgminer. You dont have to use these scripts you can install the miners that you prefer.

Now edit the miners.cfg file to set up your miners. (Notes at top of file explain format and show examples.)

Edit the scheduler.cfg to add any environmnet variables or other entries you may need.

Once you have it set up you are ready to test your settings and/or set up your crontab with your start/stop/rotate calls.

If you feel the urge to donate, feel free to uncomment one of the miner lines in the miner.cfg file and run your miner on it for a while. Those are my active mining accounts.

Thank you
