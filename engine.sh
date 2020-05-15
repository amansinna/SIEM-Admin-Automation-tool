#!/bin/bash

CONFIG=config.conf
REPORT_DIRECTORY=reports
SCRIPTS_DIRECTORY=scripts
PRECHECK_SCRIPT_FILENAME=/precheck_script.sh
POSTCHECK_SCRIPT_FILENAME=/postcheck_script.sh
DIFFCHECK_SCRIPT_FILENAME=/diffcheck_script.sh
PRECHECK_REPORT_FILENAME=/precheck_report.txt
POSTCHECK_REPORT_FILENAME=/postcheck_report.txt
DIFFCHECK_REPORT_FILENAME=/diffcheck_report.txt
L_PRECHECKSTATE=false
L_POSTCHECKSTATE=false
L_DIFFCHECKSTATE=false



init() {

	if [ ! -f "$CONFIG" ]; then
	    touch $CONFIG
	    echo "PRECHECKSTATE=false"$'\n'"POSTCHECKSTATE=false"$'\n'"DIFFCHECKSTATE=false" > $CONFIG
	    mkdir $REPORT_DIRECTORY
	    refresh_data
	    menu_items
	else
		echo
		read -p "We have active checks going on. Start new checks? (Y/N): " INIT_MENU_SELECTED

		case "$INIT_MENU_SELECTED" in
		   "N" | "n") refresh_data; menu_items
		   ;;
		   "Y" | "y") rm -rf $REPORT_DIRECTORY; rm $CONFIG; init
		   ;;
		   *) read -n 1 -s -r -p "Invalid Menu. Press any key to continue..."; init
		   ;;
		esac
	fi

}

refresh_data() {
	source $CONFIG
	L_PRECHECKSTATE=$PRECHECKSTATE
	L_POSTCHECKSTATE=$POSTCHECKSTATE
	L_DIFFCHECKSTATE=$DIFFCHECKSTATE

}

master_check() {
	refresh_data
	checkfor=$1
	case "$checkfor" in
		"precheck") if [ $L_PRECHECKSTATE == false ] && [ $L_POSTCHECKSTATE == false ] && [ $L_DIFFCHECKSTATE == false ]; then return 0; else return 1; fi
		;;
		"postcheck") if [ $L_PRECHECKSTATE == true ]; then return 0; else return 1; fi
		;;
		"diffcheck") if [ $L_PRECHECKSTATE == true ] && [ $L_POSTCHECKSTATE == true ]; then return 0; else return 1; fi
		;;
		*) return 1;
		;;
	esac

}

menu_items() {
clear >$(tty)

echo "Welcome to Qradar Upgrade Helper!"$'\n'
if [ $L_PRECHECKSTATE == true ]; then echo "1. Precheck (Done)"; else echo "1. Precheck";  fi
if [ $L_POSTCHECKSTATE == true ]; then echo "2. Postcheck (Done)"; else echo "2. Postcheck";  fi
if [ $L_DIFFCHECKSTATE == true ]; then echo "3. Diffcheck (Done)"; else echo "3. Diffcheck";  fi

read -p "Enter your choice : " MENU_SELECTED

case "$MENU_SELECTED" in
   "1") menu_precheck
   ;;
   "2") menu_postcheck
   ;;
   "3") menu_diffcheck
   ;;
   *) read -n 1 -s -r -p "Invalid Menu. Press any key to continue..."; menu_items
   ;;
esac





}

menu_precheck() {
	if  master_check precheck; then
		#your code goes here
		. "$SCRIPTS_DIRECTORY$PRECHECK_SCRIPT_FILENAME"

		sed -i "s/\("PRECHECKSTATE" *= *\).*/\1"true"/" $CONFIG 
		read -n 1 -s -r -p "Prechecks completed successfully. Press any key to continue..."; refresh_data; menu_items
	else
		echo
		read -n 1 -s -r -p "Precheck already completed. Unable to process again. Press any key to continue..."; refresh_data; menu_items
	fi
}

menu_postcheck() {
	if  master_check postcheck; then
		#your code goes here
		. "$SCRIPTS_DIRECTORY$POSTCHECK_SCRIPT_FILENAME"

		rm -f "$REPORT_DIRECTORY$DIFFCHECK_REPORT_FILENAME"
		sed -i "s/\("DIFFCHECKSTATE" *= *\).*/\1"false"/" $CONFIG 
		sed -i "s/\("POSTCHECKSTATE" *= *\).*/\1"true"/" $CONFIG 
		read -n 1 -s -r -p "Postchecks completed successfully. Press any key to continue..."; refresh_data; menu_items
	else
		echo
		read -n 1 -s -r -p "Illegal check executed. Press any key to continue..."; refresh_data; menu_items
	fi

}

menu_diffcheck() {
	if  master_check diffcheck; then
		#your code goes here
		. "$SCRIPTS_DIRECTORY$DIFFCHECK_SCRIPT_FILENAME"

		sed -i "s/\("DIFFCHECKSTATE" *= *\).*/\1"true"/" $CONFIG 
		read -n 1 -s -r -p "Diffchecks completed successfully. Press any key to continue..."; refresh_data; menu_items
	else
		echo
		read -n 1 -s -r -p "Illegal check executed. Press any key to continue..."; refresh_data; menu_items
	fi
}

init
