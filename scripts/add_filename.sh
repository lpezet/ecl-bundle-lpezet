#!/bin/bash
output=$1
delimiter=${2:-,}
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
 #echo "LINE reading..." >> /tmp/massage_3.log
 #echo "processing $LINE" >> /tmp/massage_3.log
 /opt/LPezet/prefix_records.sh "\"$(basename $LINE)\"" "$LINE" "$delimiter" >> $output
done
