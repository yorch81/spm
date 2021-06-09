#!/bin/bash

################################################################################# 
## 
## Simple Performance Monitor
## 
################################################################################ 

CURRENTDATE=$(date +%d-%m-%Y)
CURRENTTIME=$(date +%T)
MONFILE=/opt/monitor/monitor_${CURRENTDATE}.csv

# Gets CPU usage
USG_CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Gets RAM usage
USG_RAM=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

# Gets Disk usage
volume="/"
AVG_DISK=$(df -h "$volume" | egrep -o '[0-9]+%')

USG_DISK=$(echo "${AVG_DISK//%}")

# Write CSV file
if [[ ! -f "$MONFILE" ]]; then
	echo Datetime, CPU Usage, Memory Usage, Disk Usage >> ${MONFILE}
fi

echo ${CURRENTDATE} ${CURRENTTIME}, ${USG_CPU}, ${USG_RAM}, ${USG_DISK} >> ${MONFILE}

# Round CPU usage
USG_CPU=$(echo "scale=0 ; $USG_CPU/1" | bc)

# Round RAM usage
USG_RAM=$(echo "scale=0 ; $USG_RAM/1" | bc)

# Send alerts
if [[ $USG_CPU -gt 80 ]]
then
	echo Sending CPU alert
fi

if [[ $USG_RAM -gt 85 ]]
then
	echo Sending Memory alert
fi

if [[ $USG_DISK -gt 80 ]]
then
	echo Sending Disk alert
fi
