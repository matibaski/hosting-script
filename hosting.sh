#!/bin/bash

# if exit code 1, the script ended normally
# if exit code 2, the script had an error

# last update
lastupdate="19.08.2013"
lastauthor="matibaski"
version="2.0"

# include vars
sourcepath=/usr/local/bin/hosting-script
source $sourcepath/vars.sh

error_check() {
	r=$?
	if [ $r -ne 0 ] ; then
		echo "error. code: ${1} (${2})"
		exit 2
	fi
}

exit_or_hostingmanager() {
	echo ""
	echo "exit or back to the hosting manager?"
	echo "[e]xit"
	echo "[b]ack to hosting manager"
	echo "[m]ain menu"

	read -s -n 1 back_hostingmanager

	if [ $back_hostingmanager == 'e' ] ; then
		echo ""
		echo "bye"
		exit 1
	elif [ $back_hostingmanager == 'b' ] ; then
		clear
		hosting_manager
	elif [ $back_hostingmanager == 'm' ] ; then
		clear
		main_menu
	else
		echo "ERROR: invalid key pressed"
		exit_or_hostingmanager
	fi
}

exit_or_mysqlmanager() {
	echo ""
	echo "exit or back to the mysql manager?"
	echo "[e]xit"
	echo "[b]ack to mysql manager"
	echo "[m]ain menu"

	read -s -n 1 back_mysqlmanager

	if [ $back_mysqlmanager == 'e' ] ; then
		echo ""
		echo "bye"
		exit 1
	elif [ $back_mysqlmanager == 'b' ] ; then
		clear
		choose_mysql
	elif [ $back_mysqlmanager == 'm' ] ; then
		clear
		main_menu
	else
		echo "ERROR: invalid key pressed"
		exit_or_mysqlmanager
	fi
}

clear

main_menu() {
	echo "
                    __  _ __               __   _ 
   ____ ___  ____ _/ /_(_) /_  ____ ______/ /__(_)
  / __ `__ \/ __ `/ __/ / __ \/ __ `/ ___/ //_/ / 
 / / / / / / /_/ / /_/ / /_/ / /_/ (__  ) ,< / /  
/_/ /_/ /_/\__,_/\__/_/_.___/\__,_/____/_/|_/_/   
                                                  
	 "

	echo "==> WEB MANAGER <=="
	echo ""
	echo "version:     "$version
	echo "creator:     matija"
	echo "last update: "$lastupdate
	echo "last author: "$lastauthor
	echo ""
	echo "=================================================="
	echo ""

	echo "please choose an option:"
	echo ""
	echo "[h]osting manager"
	echo "[m]ysql manager"
	echo "[q]uit"
	echo ""

	read -s -n 1 menuchoose

	if [ $menuchoose == "h" ] ; then

		clear
		hosting_manager() {
			echo "  _    _           _   _             "
			echo " | |  | |         | | (_)            "
			echo " | |__| | ___  ___| |_ _ _ __   __ _ "
			echo " |  __  |/ _ \/ __| __| | '_ \ / _\` |"
			echo " | |  | | (_) \__ \ |_| | | | | (_| |"
			echo " |_|  |_|\___/|___/\__|_|_| |_|\__, |"
			echo "                                __/ |"
			echo "                               |___/ "
			echo ""
			echo "==> HOSTING MANAGER <=="
			echo ""
			echo "[1] new hosting"
			echo "[2] edit hosting"
			echo "[3] list all existing hostings"
			echo "[4] delete hosting"
			echo ""
			echo "[b] back to main menu"
			echo ""

			read -s -n 1 hostingchoose

			if [ $hostingchoose == "1" ] ; then
				# if folder already exists
				check_existing_hosting() {
					echo "create new hosting"
					echo "(Ctrl + C to quit)"
					read -p "domain: " domain

					if [ -d $hostingfolders/$domain ] || [ -f $apacheavail/$domain ]; then
						echo ""
						echo "ERROR: the domain/hosting '"$domain"' already exists"
						echo "please check the folders: "$hostingfolders" and "$apacheavail
						echo ""
						echo ""
						sleep 2
						hosting_manager
					else
						echo "" # it's a styling thing
						echo ""
					fi
				}
				check_existing_hosting

				# check for error
				error_check

				echo "=> create hosting for: "$domain
				sleep 1

				# ssl-check
				user_input_ssl () {
					echo "=> option: activate ssl?"
					echo "[y]es"
					echo "[n]o"
					read -s -n 1 ssl
					echo ""
					if [ $ssl == "y" ] ; then
						echo ""
						echo "edit apache-config afterwards to insert the correct ssl-certificate path/file:"
						echo "/etc/apache2/sites-available/"$domain
						echo ""
						apachesslinput=$apachessl
					elif [ $ssl == "n" ] ; then
						echo "no ssl activated"
						echo ""
						apachesslinput=""
					else
						echo ""
						user_input_ssl
					fi
				}
				user_input_ssl

				# check for error
				error_check

				clear

				# get apache configs
				source $sourcepath/apache.sh

				echo "--------------------------------------------------------------------------"
				echo "===== Hosting facts ====="
				echo "  domain name:  "$domain
				echo "  server name:  "$(hostname -f)
				echo "  hostingpath:  "$hostingfolders"/"$domain"/htdocs"

				if [ $ssl == "y" ] ; then
					ssltype="active"
				else
					ssltype="disabled"
				fi

				echo "  ssl:          "$ssltype
				echo "  apacheconfig: "$apacheavail"/"$domain
				echo "--------------------------------------------------------------------------"
				echo "=> REMINDER: copy & paste the code above (between the ---)"
				echo ""
				echo ""
				echo "configuration okay?"
				echo "[y]es"
				echo "[n]o"

				sure_check() {
					read -s -n 1 sure_check
					echo ""

					if [ $sure_check == "y" ] ; then
						configfile=$apacheavail/$domain
						if [ ! -f $apacheavail/$domain ] ; then
							config="${apacheconfig} ${apachesslinput}"
							touch $configfile
							echo -e $config>$configfile
							ln -s $apacheavail/$domain $apacheenable/$domain

							echo ""

							# create domainfolders & set rights
							echo "creating hosting ..."

							mkdir -p $hostingfolders/$domain/{htdocs,cgi-bin,logs}
							chown -R www-data:www-data $hostingfolders/$domain
							chmod -R 775 $hostingfolders/$domain/htdocs
							chmod -R g+s $hostingfolders/$domain/htdocs

							sleep 2
							echo "... done"
							echo ""
							echo "create test file: index.php"

							testfilepath=$hostingfolders"/"$domain"/htdocs/index.php"
							touch $testfilepath
							echo -e $testfile>$testfilepath

							echo "... done"
							echo "" 
							echo "reload apache:"

							sh /etc/init.d/apache2 reload

							echo "... done"
							echo ""
							echo ""
							
							# exit function
							exit_or_hostingmanager

						else
							echo -e "could not create hosting. please contact sysadmins (mbas/tgut)"
							echo ""

							# delete hostingfolders if existent
							if [ -d $hostingfolders/$domain ] ; then
								rm -r $hostingfolders/$domain
							fi

							# delete apache-configs if existent
							if [ -f $apacheavail/$domain ] ; then
								rm $apacheavail/$domain
							fi
							if [ -f $apacheenable/$domain ] ; then
								rm $apacheenable/$domain
							fi
							exit 1
						fi
					elif [ $sure_check == "n" ] ; then
						clear
						hosting_manager
					else
						echo "ERROR: invalid input"
						echo ""
						echo ""
						echo "=> usage:"
						echo "[y]es"
						echo "[n]o"

						sure_check
					fi
				}
				sure_check

				echo ""
				echo "==========================================================================="
				echo "your hosting is ready to go!"
				echo "please check the dns for "$domain
				echo ""
				echo "[hosting-script created by "$lastauthor" | last modification: \""$lastupdate" by "$lastauthor"\"]"
				echo ""

			elif [ $hostingchoose == "2" ] ; then
				clear
				echo "this tool is not available yet."
				hosting_manager
			elif [ $hostingchoose == "4" ] ; then
				clear

				for file in $hostingfolders/* ; do
					if [ -d $file/htdocs ] ; then
						output=${file//$hostingfolders\//}
						echo -e "- ${output}"
					fi
				done

				# if folder already exists
				check_existing_hosting() {
					echo ""
					echo "(Ctrl + C to quit)"
					read -p "domain: " domain
					if [ ! -d $hostingfolders/$domain ]; then
						echo ""
						echo "ERROR: the domain/hosting '"$domain"' does not exist"
						sleep 2
						hosting_manager
					fi
				}
				check_existing_hosting

				echo "" # it's a styling thing
				echo ""
				configfile=$apacheavail/$domain
				symlink=$apacheenable/$domain
				folders=$hostingfolders/$domain

				echo "sure you want to delete "$domain"?"

				sure_ask() {
					echo ""
					echo "[y]es"
					echo "[n]o"
					read -s -n 1 sure_ask_as
					echo ""
					if [ $sure_ask_as == "y" ] ; then
						configfile=$apacheavail/$domain
						if [ -f $apacheavail/$domain ] ; then

							# move configfile to deleted-folder
							if [ ! -d $apachedeleted ] ; then
							  mkdir $apachedeleted
							fi

							mv $configfile $apachedeleted/$domain

							echo "remove apacheconfig: \""$configfile"\""
							echo "... done"

							# remove symlink
							rm $symlink
						else
							echo "apacheconfig not found. probably deleted?"
						fi

						# create tar-file in deleted-www
						if [ -d $folders ] ; then
							if [ -d $delfolders ] ; then
								tar zcfP $delfolders/$domain.tar.gz $folders
								rm -r $folders
								echo "delete folders: \""$folders"\""
								echo "... done"
							else
								mkdir $delfolders
								tar -zcf $delfolders/$domain.tar.gz $folders
								rm -r $folders
								echo "delete folders: \""$folders"\""
								echo "... done"
							fi

							echo "" 
							echo "reload apache:"

							sh /etc/init.d/apache2 reload

							echo "... done"
							echo ""
							echo "if you want to delete the mysql database, please use the mysql-manager in the main-menu"
							echo ""
							echo ""

							# exit function
							exit_or_hostingmanager

						else
							echo "no folder found. please check: /var/www/"$domain

							# exit function
							exit_or_hostingmanager
						fi
					elif [ $sure_ask_as == "n" ] ; then
						clear
						hosting_manager
					else
						echo "ERROR: invalid input"
						echo ""
						echo ""
						echo "=> usage: sure you want to delete "$domain"?"
						echo "[y]es"
						echo "[n]o"
						sure_ask
					fi
				}
				sure_ask

			elif [ $hostingchoose == "3" ] ; then
				clear
				echo "listing all existing hostings:"
				echo ""

				for file in $hostingfolders/* ; do
					if [ -d $file/htdocs ] ; then
						echo "- "${file//$hostingfolders\//}
					fi
				done

				echo ""
				echo ""

				hosting_manager
			elif [ $hostingchoose == "b" ] ; then
				clear
				main_menu
			else
				clear
				echo "ERROR: invalid input"
				hosting_manager
			fi
		}
		hosting_manager

	elif [ $menuchoose == "m" ] ; then
		clear
		choose_mysql() {
			echo "  __  __        _____  ____  _      "
			echo " |  \/  |      / ____|/ __ \| |     "
			echo " | \  / |_   _| (___ | |  | | |     "
			echo " | |\/| | | | |\___ \| |  | | |     "
			echo " | |  | | |_| |____) | |__| | |____ "
			echo " |_|  |_|\__, |_____/ \___\_\______|"
			echo "          __/ |                     "
			echo "         |___/     "
         	echo ""
			echo "==> MYSQL MANAGER <=="
			echo ""
			echo "combined functions:"
			echo "[1] add new user & database"
			echo ""
			echo "plain functions:"
			echo "[2] change password for user"
			echo "[3] delete user"
			echo "[4] delete database"
			echo "[5] add new user"
			echo "[6] add new database"
			echo ""
			echo "list functions:"
			echo "[7] list databases"
			echo "[8] list users"
			echo ""
			echo "[b] back to main menu"
			echo ""
			read -s -n 1 mysql_menu

			if [ $mysql_menu == "1" ] ; then
				user_input_mysql () {

					mysql_dev() {
						echo ""
						echo "do you want a additional dev-database?"
						echo "[y]es"
						echo "[n]o"
						echo ""
						read -s -n 1 mysql_dev_choose

						if [ $mysql_dev_choose == 'y' ] ; then
							dev_db='true'
						elif [ $mysql_dev_choose == 'n' ] ; then
							dev_db='false'
						else
							echo ""
							echo "ERROR: wrong key"
							mysql_dev
						fi
					}
					mysql_dev

					echo "create database-access"
					echo "please set a prefix for your site."
					echo "for example:"
					echo ""
					echo "cake website:        cake_website"
					echo "contao website:      ct_website"
					echo "wordpress website:   wp_website"

					check_mysql_userdata() {
						echo ""
						read -p "mysql username: " my_user
						read -p "mysql password: " my_pass
						read -p "mysql database: " my_db
						dev_db_name=${my_db}"-dev"

						# check username length
						if [ ${#my_user} -gt 16 ] ; then
							echo "ERROR: the username mustn't be longer than 16 characters"
							check_mysql_userdata
						fi

						# check database-name length
						if [ ${#my_db} -gt 16 ] ; then
							echo "ERROR: the database-name mustn't be longer than 16 characters"
							check_mysql_userdata
						fi

						# check for existing user
						checkuser=`mysql -u $mysqlroot -p$rootpw -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$my_user') ;"`
						lastchr=${checkuser#${checkuser%?}}
						if [ $lastchr -eq 1 ] ; then
							clear
							echo "ERROR: mysql user exists"
							echo ""
							echo "creating mysql & database..."
							check_mysql_userdata
						fi

						# check for existing database
						if [[ -z "`mysql -u $mysqlroot -p$rootpw "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$my_db'" 2>&1`" ]] ; then
							clear
							echo "ERROR: database already exists..."
							echo ""
							echo "creating mysql & database"
							check_mysql_userdata
						fi

						# check for existing dev-database
						if [ $dev_db == 'true' ] ; then
							if [[ -z "`mysql -u $mysqlroot -p$rootpw "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$my_db'" 2>&1`" ]] ; then
								clear
								echo "ERROR: database already exists"
								echo ""
								echo "creating mysql & database"
								check_mysql_userdata
							fi
						fi
					}
					check_mysql_userdata

					mysql -u $mysqlroot -p$rootpw -e "CREATE DATABASE \`$my_db\`;"
					mysql -u $mysqlroot -p$rootpw -e "CREATE USER \`$my_user\`@'localhost' IDENTIFIED BY '${my_pass}';"
					mysql -u $mysqlroot -p$rootpw -e "GRANT USAGE ON * . * TO \`$my_user\`@'localhost' IDENTIFIED BY '${my_pass}' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;"
					mysql -u $mysqlroot -p$rootpw -e "GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER ON \`$my_db\` . * TO \`$my_user\`@'localhost';"

					if [ $dev_db == 'true' ] ; then
						mysql -u $mysqlroot -p$rootpw -e "CREATE DATABASE  \`$dev_db_name\`;"
						mysql -u $mysqlroot -p$rootpw -e "GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER ON \`$dev_db_name\` . * TO \`$my_user\`@'localhost';"
					fi

					echo "--------------------------------------------------------------------------"
					echo "===== MySQL facts ====="
					echo "  server name: "$(hostname -f)
					echo "  db-host:     localhost"
					echo "  db-user:     "$my_user
					echo "  password:    "$my_pass
					echo "  db-name:     "$my_user

					if [ $dev_db == 'true' ] ; then
						echo "  dev-db-name: "$dev_db_name
					fi

					echo "--------------------------------------------------------------------------"
					echo "=> REMINDER: copy & paste the code above (between the ---)"
					echo ""

					# exit function
					exit_or_mysqlmanager
				}
				user_input_mysql

			elif [ $mysql_menu == "2" ] ; then

				clear
				change_mysql_user_pw() {
					echo "changing password for mysql username..."
					echo ""
					read -p "please enter the username: " change_pw_my_user
					echo ""

					if [[ -z "$change_pw_my_user" ]] ; then
						clear
						change_mysql_user_pw
					fi

					check_existing_my_user=`mysql -u $mysqlroot -p$rootpw -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$change_pw_my_user') ;"`
					lastchr=${check_existing_my_user#${check_existing_my_user%?}}

					if [ $lastchr == 1 ] ; then
						read -p "enter new password: " change_pw_my_user_password

						mysql -u $mysqlroot -p$rootpw -e "USE mysql; UPDATE mysql.user SET password=PASSWORD('$change_pw_my_user_password') WHERE user='$change_pw_my_user'; FLUSH PRIVILEGES;"
						
						error_check 'change_mysql_user_pw' '543-579'

						echo ""
						echo "... done"
						echo "please note down the new password (on your host or in the coundco-wiki)"
						echo ""

						# exit function
						exit_or_mysqlmanager
					else
						clear
						echo "ERROR: mysql user does not exist"
						echo ""
						change_mysql_user_pw
					fi

					# exit function
					exit_or_mysqlmanager
				}
				change_mysql_user_pw

			elif [ $mysql_menu == "3" ] ; then
				
				clear
				delete_mysql_user() {
					echo "delete mysql user..."
					echo ""
					read -p "please enter the username: " delete_my_user
					echo ""

					if [[ -z "$delete_my_user" ]] ; then
						clear
						delete_mysql_user
					fi

					check_existing_my_user=`mysql -u $mysqlroot -p$rootpw -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$delete_my_user') ;"`
					lastchr=${check_existing_my_user#${check_existing_my_user%?}}

					if [ $lastchr == 1 ] ; then

						echo "do you really want to delete the user: "$delete_my_user
						echo "[y]es"
						echo "[n]o"
						echo ""
						read -s -n 1 ack_delete_user

						sure_ask_delete_user() {
							if [ $ack_delete_user == "y" ] ; then
								# delete the user
								echo "deleting ..."
								echo ""

								mysql -u $mysqlroot -p$rootpw -e "USE mysql; DELETE FROM mysql.user WHERE user='$delete_my_user'; FLUSH PRIVILEGES;"
								error_check 'delete_mysql_user' '590'
								sleep 1

								echo ""
								echo "... done"
								echo "the user ${delete_my_user} has been deleted"
								echo ""

								# exit function
								exit_or_mysqlmanager

							elif [ $ack_delete_user == "n" ] ; then
								echo "aborting ..."
								echo ""
								# exit function
								exit_or_mysqlmanager
							else
								echo "ERROR: invalid input"
								sure_ask_delete_user
							fi
						}
						sure_ask_delete_user
					else
						clear
						echo "ERROR: mysql user does not exist"
						echo ""
						delete_mysql_user
					fi

					# exit function
					delete_mysql_user
				}
				delete_mysql_user

			elif [ $mysql_menu == "4" ] ; then
				
				clear
				drop_database_mysql() {

					echo "delete database ..."
					echo ""
					read -p "please enter the database-name: " database_name

					if [[ -z "$database_name" ]] ; then
						clear
						echo "ERROR: database does not exist (1)"
						drop_database_mysql
					fi

					# check for existing database
					if [[ ! -z "`mysql -u $mysqlroot -p$rootpw -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$database_name'" 2>&1`" ]] ; then
						
						sure_ask_drop_database() {
							echo ""
							echo "are you sure you want to delete "$database_name"?"
							echo "[y]es"
							echo "[n]o"
							read -s -n 1 ack_drop_database

							if [ $ack_drop_database == "y" ] ; then
								echo ""
								echo "deleting database "$database_name" ..."
								mysql -u $mysqlroot -p$rootpw -e "DROP DATABASE $database_name;"

								sleep 1
								echo ""
								echo "... done"

								# exit function
								exit_or_mysqlmanager

							elif [ $ack_drop_database == "n" ] ; then
								clear
								echo ""
								echo "aborting ..."

								# exit function
								exit_or_mysqlmanager
							else
								echo "ERROR: invalid input"
								sure_ask_drop_database
							fi
						}
						sure_ask_drop_database
						
					else
						clear
						echo "ERROR: database does not exist (2)"
						drop_database_mysql
					fi
					drop_database_mysql
				}

				drop_database_mysql

			elif [ $mysql_menu == "5" ] ; then
				
				clear
				create_mysql_user() {
					echo "creating mysql user ..."
					echo ""
					read -p "enter username: " user_name

					if [[ -z "$user_name" ]] ; then
						clear
						echo "username mustn't be empty!"
						echo ""
						create_mysql_user
					fi

					# check username length
					if [ ${#my_user} -gt 16 ] ; then
						clear
						echo "ERROR: the username mustn't be longer than 16 characters"
						echo ""
						user_name
					fi

					# check for existing user
					checkuser=`mysql -u $mysqlroot -p$rootpw -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$user_name') ;"`
					lastchr=${checkuser#${checkuser%?}}
					if [ $lastchr == 1 ] ; then
						clear
						echo "ERROR: mysql user exists"
						echo ""
						create_mysql_user
					else
						set_password() {
							read -p "password: " user_name_password

							if [[ -z $user_name_password ]] ; then
								echo "password mustn't be empty!"
								set_password
							else
								echo "creating mysql user "$user_name" ..."

								mysql -u $mysqlroot -p$rootpw -e "CREATE USER '$user_name'@'localhost' IDENTIFIED BY '$user_name_password'; FLUSH PRIVILEGES;"
								sleep 1

								echo "user "$user_name" was added with the password: "$user_name_password
								echo ""
								echo "HINT: the user does not have any rights. you have to give rights to the user over phpmyadmin-panel!"
								echo "don't forget to save this data somewhere (wiki.coundco.local or somewhere else)"

								# exit function
								exit_or_mysqlmanager
							fi
						}
						set_password
					fi
				}
				create_mysql_user

			elif [ $mysql_menu == "6" ] ; then

				clear
				create_database_mysql() {

					echo "create database ..."
					echo ""
					read -p "please enter the database-name: " database_name

					if [[ -z "$database_name" ]] ; then
						clear
						echo "ERROR: database mustn't be empty"
						create_database_mysql
					fi

					# check database-name length
					if [ ${#database_name} -gt 16 ] ; then
						clear
						echo "ERROR: the database-name mustn't be longer than 16 characters"
						echo ""
						create_database_mysql
					fi

					# check for existing database
					if [[ -z "`mysql -u $mysqlroot -p$rootpw -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$database_name'" 2>&1`" ]] ; then
						
						sure_ask_create_database() {
							echo ""
							echo "are you sure you want to create "$database_name"?"
							echo "[y]es"
							echo "[n]o"
							read -s -n 1 ack_create_database

							if [ $ack_create_database == "y" ] ; then
								echo ""
								echo "creating database "$database_name" ..."
								mysql -u $mysqlroot -p$rootpw -e "CREATE DATABASE $database_name;"

								sleep 1
								echo ""
								echo "... done"

								# exit function
								exit_or_mysqlmanager

							elif [ $ack_create_database == "n" ] ; then
								clear
								echo ""
								echo "aborting ..."

								# exit function
								exit_or_mysqlmanager
							else
								echo "ERROR: invalid input"
								sure_ask_create_database
							fi
						}
						sure_ask_create_database
						
					else
						clear
						echo "ERROR: database already exists"
						create_database_mysql
					fi
					create_database_mysql
				}
				create_database_mysql

			elif [ $mysql_menu == "7" ] ; then
				
				clear
				echo "listing all databases ..."
				echo ""
				mysql -u $mysqlroot -p$rootpw -e "SHOW DATABASES;"

				# exit function
				exit_or_mysqlmanager

			elif [ $mysql_menu == "8" ] ; then

				clear
				echo "listing all mysql users ..."
				echo ""
				echo "HINT: the privileges are set per database, not global."
				echo "      to change privileges, do it in the phpmyadmin-panel"
				echo ""
				mysql -u $mysqlroot -p$rootpw -e "SELECT user, host FROM mysql.user;"

				# exit function
				exit_or_mysqlmanager

			elif [ $mysql_menu == "b" ] ; then
				clear
				main_menu
			else
				clear
				echo "ERROR: wrong key pressed"
				choose_mysql
			fi
		}
		choose_mysql

	elif [ $menuchoose == "q" ] ; then
		echo ""
		echo ""
		echo "bye"
		echo ""
		exit 1
	else
		clear
		echo "ERROR: invalid input"
		main_menu
	fi
}
main_menu
