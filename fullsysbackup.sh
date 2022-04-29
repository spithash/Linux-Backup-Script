#!/usr/bin/env bash

###### Configuration ######

# Enter the backup location - Where should we save our files? (You should change this)
backuplocation="/home/user/fullsysbackup"

# Enter full paths of folders to include in our backup archive. (You should change these)
backuppaths=(
  /home/user 
  /root 
  /etc 
  /usr/share/coreruleset 
  /usr/share/grc 
  /var 
  /lib/systemd/system
)
###### End Of Configuration ######

# sudo is required
printf "\e[1mThis script needs sudo privileges. You will also be promped to enter mysql credentials for each database you export unless you have a .my.cnf file in place. See README.md\e[0m\n"
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

printf "%b" "\e[1mChecking for required package: pv\e[0m\n"
sleep 1
FILE=/usr/bin/pv
if [ -f "$FILE" ]; then
    printf "%b" "\e[1m$FILE exists.\e[0m\n"
else 
    printf "%b" "\e[31m$FILE does not exist. You may install it with "sudo apt install pv" or your distros package manager. - Script will now exit.\e[0m\n" && exit 0
fi

FILE1=/bin/gzip
if [ -f "$FILE1" ]; then
    printf "%b" "\e[1m$FILE1 exists.\e[0m\n"
else 
    printf "%b" "\e[31m$FILE1 does not exist. You may install it with "sudo apt install gzip" or your distros package manager. - Script will now exit.\e[0m\n" && exit 0
fi

printf "%b" "\e[1mBacking up to: $backuplocation\e[0m\n"
today=$(date +"%Y-%m-%d-%I-%M-%p")
sleep 1
mkdir -p $backuplocation

printf "%b" "\e[1mDumping Databases... Your mysql root password is required\e[0m\n"

mysql -N -e 'show databases' -u root -p |grep -v 'mysql\|information\|performance'|
while read -r dbname;
do 
  if mysqldump --verbose --complete-insert --routines --triggers --single-transaction -u root -p "$dbname" > $backuplocation/"$dbname"-"${today}".sql; [[ $? -eq 0 ]] && gzip --force $backuplocation/"$dbname-${today}".sql; then
  printf "%b" "\e[31mDumping Database: \e[1m $dbname \e[32mdone.\e[0m\n" 
else
  printf "%b" "\e[31mCould not dump \e[1m $dbname \e[31mdatabase\e[0m\n" && exit 0
fi
done

sleep 1
  printf "%b" "\e[1mBacking up system and user files...\e[0m\n"

# TODO: dialog output
#if (tar -cf - "${backuppaths[@]}" --exclude="$backuplocation" | pv -s $(du -cb "${backuppaths[@]}" | tail -1 | awk '{print $1}') | gzip --force > archive.tar.gz) 2>&1 | dialog --gauge "Backing up your files..." 7 70; then
#

if tar -cf - "${backuppaths[@]}" --exclude="$backuplocation" | pv -s $(du -cb "${backuppaths[@]}" | tail -1 | awk '{print $1}') | gzip --force > $backuplocation/backup-files-"$today".tar.gz ; then
    printf "%b" "\e[31mSystem and user files backup: \e[32mdone.\e[0m\n"
  else
    printf "%b" "\e[31mError: Could not backup files.\e[0m\n" && exit 0  
fi

printf "%b" "\e[32mDone!\e[0m"
exit 0
