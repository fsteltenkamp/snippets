#!/bin/bash
LOG=/root/wg_check.log
LOCKFILE=/root/.wg_check_in_progress
RESTARTFILE=/root/.wg_restarted
GATEWAY=IP_TO_PING_HERE
if [ -f $LOCKFILE ]; then
    echo "~scheduled check skipping, check in progress" >> $LOG
else
    touch $LOCKFILE
    echo "========$(date)========" >> $LOG
    echo "Checking LAN Gateway Availability." >> $LOG
    if ping -c 1 $GATEWAY &> /dev/null
    then
        echo "Gateway reached. no action taken." >> $LOG
        if [ -f "$RESTARTFILE" ]; then
            echo "Lockfile found, but gateway available again. removing lockfile." >> $LOG
            rm $RESTARTFILE
        fi
    else
        echo "Gateway not available." >> $LOG
        echo "Restarting Wireguard Interface." >> $LOG
        if [ -f "$LOCKFILE" ]; then
            echo "Lockfile found. We restarted wireguard in the previous run. waiting for another round." >> $LOG
            rm $RESTARTFILE
        else
            wg-quick down wg0
            sleep 1
            wg-quick up wg0
            echo "Restart finished. Pinging gateway to check if its up again." >> $LOG
            touch $RESTARTFILE
            if ping -c 1 $GATEWAY &> /dev/null
            then
                echo "Gateway Reachable again." >> $LOG
            else
                echo "Gateway still not responding." >> $LOG
            fi
        fi
    fi
    #finish run by removing lockfile
    rm $LOCKFILE
    #Truncate Logfile to last 1000 Lines:
    echo "$(tail -1000 $LOG)" > $LOG
fi