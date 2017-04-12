hosting-script
==============

Hosting script to create, manage and delete webhostings on a linux server via terminal.

The script contains following options:

- web manager
  - new hosting
  - edit hosting
  - list all existing hostings
  - delete hosting

- mysql manager
  - add new user & database
  - change password for specific user
  - delete user
  - delete database
  - add new user
  - add new database
  - list databases
  - list users

how to install
==============

download the repo and move it to:
> /usr/local/bin/hosting-script

give permissions:
> chmod +x /usr/local/bin/hosting-script/hosting.sh

change the sourcepath in 
> /usr/local/bin/hosting-script/hosting.sh

on line 12 (if you are using a different location)

change the settings under
> /usr/local/bin/hosting-script/vars.sh

with your paths and configs

contact
==============
problems, questions, ideas?
write me an e-mail (info -at- matibaski.ch) or visit my website www.matibaski.ch
