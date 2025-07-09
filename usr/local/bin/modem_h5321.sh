#!/bin/sh

#Bus /dev/usb Device /dev/ugen0.2: ID 0bdb:1926 Ericsson Business Mobile Networks BV H5321 gw Mobile Broadband Module

# ttyACM0 : H5321 gw Mobile Broadband Modem
MODEM_DEVICE="/dev/ttyU0"

# ttyACM1 : H5321 gw Mobile Broadband Data Modem
DATA_MODEM_DEVICE="/dev/ttyU1"

# ttyACM2 : H5321 gw Mobile Broadband GPS Port
GPS_DEVICE="/dev/ttyU2"

# cdc-wdm0 : H5321 gw Mobile Broadband Device Management
# cdc-wdm1 : H5321 gw Mobile Broadband USIM Port

USB_ID="0bdb:1900"
PIN=""
APN="internet.digimobil.es"

printf "AT\r" | cu -l /dev/ttyU0 -s 115200
sleep 2
printf "AT\r" | cu -l /dev/ttyU1 -s 115200
sleep 2
printf "AT\r" | cu -l /dev/ttyU2 -s 115200
sleep 2

#NO PIN
powerup_H5321 () {
	printf "Turning on H5321 card on $MODEM_DEVICE Without PIN\n"
	sleep 1
	printf "AT+CPIN?\r" > $MODEM_DEVICE
    timeout 4 cat < $MODEM_DEVICE
	printf "AT+CFUN=1\r" > $MODEM_DEVICE
	timeout 4 cat < $MODEM_DEVICE
	printf "done\n"
	sleep 1
}

powerdown_H5321 () {
	printf "Turning off F3507g card...\n"
	printf "AT+CFUN=4\r" > $MODEM_DEVICE
	timeout 4 cat < $MODEM_DEVICE
	printf "done\n"
}

configure_GPS () {
    printf "Configure the GPS receiver to update every second and turn DGPS on,\n"
	printf "AT*E2GPSCTL=$1,$2,$3\r" > $DATA_MODEM_DEVICE
    timeout 5 cat < $DATA_MODEM_DEVICE
	printf "done\n"
}

#NMEA
  #  X can be 0 (NMEA stream turned off) or 1 (NMEA stream turned on)
  #  Y can be an integer form 1 to 60, and sets the frequency of how often the card emits the NMEA sentences
  #  Z can be 0 (DGPS is turned off) or 1 (DGPS is turned on)
turnon_GPS () {
	configure_GPS 1 1 1
	printf "Starting NMEA stream on $GPS_DEVICE...\n"
	printf "AT*E2GPSNPD\r" > $GPS_DEVICE
	timeout 5 cat < $GPS_DEVICE
	printf "done\n"
}

turnoff_GPS () {
	printf "Stopping NMEA stream on $DATA_MODEM_DEVICE...\n"
	configure_GPS 0 1 0
	PID=$(cat /var/run/gpsd.pid)
	if [ -n "$PID" ]; then
	  kill -9 "$PID"
	else
	  printf "gpsd not found.\n"
	fi
	printf "done\n"
	sleep 5
}

turnon_WWAN () {
	printf "Starting WWAN connection...\n"
	/usr/bin/chat -v -s -t 5 "" "AT+CGDCONT=1,\"IP\",\"$APN\"" "OK" "AT*ENAP=1,1" "OK" > $MODEM_DEVICE < $MODEM_DEVICE
	printf "done\n"
	sleep 5
}

turnoff_WWAN () {
	printf "Stopping WWAN connection...\n"
	/usr/bin/chat -v -s -t 5 "" "AT*ENAP=0" "OK" > $MODEM_DEVICE < $MODEM_DEVICE
	printf "done\n"
	sleep 5
}

if [ ! -f /usr/local/sbin/gpsd ]; then
	printf "WARNING: gpsd does not exist. "
	printf "Please install gpsd: pkg install astro/gpsd\n"
fi

while true;
do
	printf "Select An Action: \n"
	printf "1) Power Up Modem H5321\n"
	printf "2) Turn On GPS\n"
	printf "3) Power Down Modem H5321\n"
	printf "4) Turn Off GPS\n"
	printf "5) Exit\n"
	printf "Enter number: "
	read NUMBER

	case $NUMBER in
		1)
			powerup_H5321
			;;
		2)
			turnon_GPS
			;;
		3)
			powerdown_H5321
			;;
		4)
			turnoff_GPS
			;;
		5)
			printf "Exit From Menu.\n"
			exit 0
			;;
		*)
			echo -n "Invalid option $NUMBER"
			;;
	esac
	clear
done

