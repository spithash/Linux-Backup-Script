# Linux Backup Script (Bash)
Take backups of your mysql/mariadb databases and your files/folders. This can be useful for server backups or migrations.
I personaly use it to backup all of /etc/ and maybe home user directories including websites and databases that I maintain.
Makes my life easier not having to go through all the progress again and again. I just change the folder paths to the ones I need and I'm ready to go.

# Requirements
Package **pv** is required to be installed on your system because it's needed for the progress bar when creating the file archives.
Use your favourite package manager and install it. on Debian: **sudo apt install pv**

# MySQL/MariaDB
The script will ask for mysql user and password confirmation each time you dump a database.
## .my.cnf – mysql user & password
Create file ~/.my.cnf and add following lines in it and replace mysqluser & mysqlpass values.
```
[client]
user=mysqluser
password=mysqlpass
```
For safety, make this file readable to you only by running chmod 0600 ~/.my.cnf 

# TODO: 
* Make it work with dialog for a fancy progress bar.
* Maybe use rsync to copy files to a remote machine?

