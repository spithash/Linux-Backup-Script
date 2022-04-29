# Linux Backup Script (Bash)
Take backups of your mysql/mariadb databases and your files/folders. This can be useful for server backups or migrations.
I personaly use it to backup all of /etc/ and maybe home user directories including websites and databases that I maintain.
Makes my life easier not having to go through all the progress again and again. I just change the folder paths to the ones I need and I'm ready to go.
The script will use gzip to create .gz archives of your files.

# Requirements
Packages **pv & gzip** are required to be installed on your system because they're needed for the progress bar and archive creation of your files and .sql databases.
Use your favourite package manager and install them.
On Debian this should do: **sudo apt install pv gzip**

# MySQL/MariaDB
The script will ask for mysql user and password confirmation each time you dump a database.
If this bothers you, then you should create a .my.cnf file (see below) and **also** you should remove "-u root -p" from the mysql commands to avoid trying to connect as root if ***you don't have to***.

## .my.cnf – mysql user & password
Create file ~/.my.cnf and add following lines in it and replace mysqluser & mysqlpass values.
```
[client]
user=mysqluser
password=mysqlpass
```
For safety, make this file readable to you only by running chmod 0600 ~/.my.cnf 

# Usage
Just run it with: **bash fullsysbackup.sh**

# TODO: 
* Make it work with dialog for a fancy progress bar.
* Maybe use rsync to copy files to a remote machine?

