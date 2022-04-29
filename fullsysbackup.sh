#!/usr/bin/env bash

###### Configuration ######

# Enter the backup location - Where should we save our files?
backuplocation="/root/fullsysbackup"

# Enter full paths of folders to include in our backup
backuppaths=(
  /home/spithash 
  /root 
  /etc 
  /usr/share/coreruleset 
  /usr/share/grc 
  /var 
  /lib/systemd/system
)
###### End Of Configuration ######

# sudo is required
if [[ $UID != 0 ]]; then
    echo "Permission Denied: run this script with sudo privileges. You will also be promped to enter mysql credentials."
    echo "sudo $0 $*"
    exit 1
fi

# Let's wait for CTRL+C signals
trap ctrl_c INT

function ctrl_c() {
        echo -e "\e[31m*** Stopping the script, CTRL-C pressed.\e[0m"
}

echo ""
echo -e "\e[1mChecking for required package: pv\e[0m"
sleep 1
FILE=/usr/bin/pv
if [ -f "$FILE" ]; then
    echo -e "\e[1m$FILE exists.\e[0m"
else 
    echo -e "\e[31m$FILE does not exist. You may install it with "sudo apt install pv" - Script will now exit.\e[0m" && exit 0
fi

echo ""
echo -e "\e[1mBacking up to: $backuplocation\e[0m"
today=$(date +"%Y-%m-%d-%I-%M-%p")
sleep 1
mkdir -p $backuplocation
echo ""
echo -e "\e[1mDumping Databases... Your mysql root password is required\e[0m"
echo ""

mysql -N -e 'show databases' -u root -p |grep -v 'mysql\|information\|performance'|
while read dbname;
do 
  if mysqldump --verbose --complete-insert --routines --triggers --single-transaction -u root -p "$dbname" > $backuplocation/"$dbname"-${today}.sql; [[ $? -eq 0 ]] && gzip --force $backuplocation/"$dbname-${today}".sql; then
  echo -e "\e[31mDumping Database: \e[1m $dbname \e[32mdone.\e[0m" 
else
  echo -e "\e[31mCould not dump \e[1m $dbname \e[31mdatabase\e[0m" && exit 0
fi
done

sleep 1
echo ""
  echo -e "\e[1mBacking up system and user files...\e[0m"

# TODO: dialog output
#if (tar -cf - "${backuppaths[@]}" | pv -s $(du -cb "${backuppaths[@]}" | tail -1 | awk '{print $1}') | gzip --force > archive.tar.gz) 2>&1 | dialog --gauge "Backing up your files..." 7 70; then
#

if tar -cf - "${backuppaths[@]}" | pv -s $(du -cb "${backuppaths[@]}" | tail -1 | awk '{print $1}') | gzip --force > $backuplocation/backup-files-$today.tar.gz ; then
    echo -e "\e[31mSystem and user files backup: \e[32mdone.\e[0m"
  else
    echo -e "\e[31mError: Could not backup files.\e[0m" && exit 0  
fi

echo ""
echo -e "\e[32mDone!\e[0m"
exit 0
