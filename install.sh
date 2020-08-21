#!/bin/bash
#
#
clear
echo "***********************************************************"
echo "|             Mining-Scheduler Installer                  |"
echo "***********************************************************"
echo ""
echo ""

#
# Request install location
#
echo -n "Enter the location to install [/opt/mining-scheduler]:"
read LOCATION
if [ -z $LOCATION ]; then
   LOCATION="/opt/mining-scheduler"
fi
echo "Install Location set to "$LOCATION
echo -n "Is this correct? "
read ANSWER
ANS=`echo "$ANSWER" | tr '[:upper:]' '[:lower:]'`
if [[ ${ANS} == "n" || ${ANS} == "no" ]]; then echo "Please restart the installer"; exit 0; fi
if [[ ${ANS} == "y" || ${ANS} == "yes" ]]; then
  LKEY="<DIR>"
fi
#
# Who owns the process?
#
  echo -n "Will your miner and mining scheduler be running as root? [Y/n] "
  read ASROOT
  if [ -z $ASROOT ]; then
   ASROOT="y"
  fi
  ASROOT=`echo "$ASROOT" | tr '[:upper:]' '[:lower:]'`


  if [[ $ASROOT == "n" || $ASROOT == "no" ]]; then
    echo -n "What is the name of the user the miner and mining-scheduler will run as? "
    read MUSER
  fi
  if [[ $ASROOT == "y" || $ASROOT == "yes" ]]; then
    echo "Setting mining-scheduler to run as root"
    MUSER="root"
  fi
  if [ -z $MUSER ]; then
     echo "Please restart the installer"
     exit 5
   fi
  UKEY="<USER>"
  
#
# Should we start at boot?
#
  echo -n "Should we start the miner at boot? [Y/n]"
  read $SBOOT
  if [ -z $SBOOT ]; then
   SBOOT="y"
  fi
  ASROOT=`echo "$SBOOT" | tr '[:upper:]' '[:lower:]'`
  if [[ $SBOOT == "n" || $SBOOT == "no" ]]; then
    echo "Setting mining-scheduler to not start at boot"
    TEST="1"
  fi
  if [[ $SBOOT == "y" || $SBOOT == "yes" ]]; then
    echo "Setting mining-scheduler to start at boot"
    TEST="1"
  fi
  if [[ ! $TEST == "1" ]]; then
     echo "Invalid input"
     exit 5
   fi
 

#
# Modify mining-scheduler.service
#
  echo "Setting install location in systemd service file"
  sed -i "s~$LKEY~$LOCATION~" mining-scheduler.service
  echo "Done"
  echo "Setting user in systemd service file"
  sed -i "s~$UKEY~$MUSER~" mining-scheduler.service
  echo "Done"
  echo ""

#
# Modify scheduler.cfg
#
  echo "Setting \$MHOME in scheduler.cfg"
  sed -i "s~$LKEY~$LOCATION~" scheduler.cfg
  echo "Done"
  echo ""

#
# Copy files to install location
#
  echo "Installing mining-scheduler in "$LOCATION
  cp -r . $LOCATION
  chown -R ${MUSER} $LOCATION
  echo "Done"
  echo ""
#
# Install mining-scheduler.service and Reload systemd
#
  echo "Installing systemd service file"
  cp mining-scheduler.service /usr/lib/systemd/system
  systemctl daemon-reload
  if [[ $SBOOT == "y" ]] || [[ $SBOOT == "yes" ]]; then
     echo "Enabling mining-scheduler at boot"
     systemctl enable mining-scheduler
     echo "Done"
     echo ""
  fi
  echo "Done"
  echo ""
  echo "Install Finished"
#
# Exit
#
