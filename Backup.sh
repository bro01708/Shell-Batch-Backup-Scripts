#!/bin/bash
#this method is called when the menu route is used to do the backup (if the params arent valid)
#it requests a dir name until it detects a valid one and then sets the dir name to the targ variable
GetTarg()
{
	while [[ ! -d $targ ]]
		do
		read -e -p "Please Enter TARGET directory: " targ
	done
}

#this method reads in a variable for a destination, checks it exists, and if not, prompts for creation of the destination 
GetDest()
{
	read -e -p "Please Enter DESTINATION directory: " dest
	if [[ -d $dest ]]
	then
		echo "Destination Found"
	fi
	if [[ ! -d $dest ]]
	then
		read -r -p "Destination not found, create? [y/n] " response
		case "$response" in
			y|Y) echo "Creating"
				mkdir $dest
				;;
			n|N) echo "Returning To Menu"
				targ="nulltarg"
				dest="nulldest"
				 menu
				;;
			*) echo "Invalid Input" 
				;;
		esac
	fi
}

#backs up the target to the destination and appends a datestamp for version control at the 
#end of the folder name.
#Then resets the targ and dest params to avoid conflict when another backup is performed
AdHoc()
{
	cp -r -v $targ $dest/$(basename $targ)$(date +%Y%m%d%T)
	targ="nulltarg"
	dest="nulldest"
}

#creates a new sh file which contains a simple backup script that can be run separately to this script
NewBackup()
{
read -p "Please enter filename for new batch file; " bname
echo "Creating Backup File"
echo "#!/bin/bash" >> $bname.sh
echo "if [ ! -d "$dest"]; then mkdir "$dest"; fi" >> $bname.sh
echo cp -r -v $targ $dest/$(basename $targ)'$(date '+%Y%m%d%T')' >> $bname.sh
chmod +x $bname.sh
}

#Creates a dynamic array for collecting alot of targets all to be backed up to one destion
#The end of the user entries is signalled by submitting a blank entry.
#Then loops through each index of the array and applies the Ad-Hoc method using the targ variable in the array
MultiBack()
{
echo "Provide your entries followed by [enter] each time. To signal the end of the list, submit a blank entry."
count=0
lastentry="default"

while [[ $lastentry != "" ]]
do
	read -p "Enter Target; " temp
	targetarray[$count]=$temp
	lastentry=$temp
	count=$count+1
done
echo ${targetarray[*]}
for i in "${targetarray[*]}"
do
	targ=$i
	AdHoc
done

}

#Simple explanation of the menu options for easier use.
Help()
{
cat<<EOF
Adhoc - This selection allows you to select a folder you wish to back up and a destination where you would like it to be backed up to. If the destination isnt found, it can then create it for you.

NewBackupFile - This selection allows you to create a backup script that you can run separately to this script that automatically performs a pre-determined backup from the Command Line.

MultipleBackups - This selection allows you to choose multiple folders that you wish to backup to one destination. To signal the end of the list of the entries for target folders, submit a blank entry (Just hit Enter)

Command Line Mode - You can do backups straight from the command line. Simply run the file with the first parameter being the target folder, and the second being the destination.

EOF
}

#Method to prompt before moving onto another stage of the the script
Confirm()
{
read -p "press enter to continue" 
}

#Allows user to select from several prompts to choose functionality.
#Returns to menu till script termination
Menu()
{
while :
do
clear
    cat<<EOF
SID - 1543319
==============================
Automated Backup Program v3
------------------------------
Please enter your choice:
AdHoc           (1)
NewBackupFile   (2)
MultipleBackups (3)
Help            (4)
Exit            (Q)
==============================
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  echo "1 - AdHoc" ; GetTarg ; GetDest ; AdHoc;;
    "2")  echo "2 - NewBackupFile" ; GetTarg ; GetDest ; NewBackup ;;
    "3")  echo "3 - MultipleBackups" ; GetDest ; MultiBack ;;
    "4")  Help ;;
    "Q")  echo "Exiting" ; break ;;
    "q")  echo "case sensitive!!"   ;; 
     * )  echo "invalid option"     ;;
    esac
    Confirm
done	
}
#defining global variables to be used for passing the cmd var into
targ="nulltarg"
dest="nulldest"
	
#Test to check for valid/present command line params
#if present, do Adhoc function
#Converts command variables into usable variables
#else launch menu as failsafe
if [[ $# = 2 ]] && [[ -d $1 ]]; then
	targ=$1
	dest=$2
	if [[ ! -d $dest ]]; then	
		mkdir $dest
	fi
	AdHoc
else
	echo Defauling to Menu
	Menu
fi
