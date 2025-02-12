#!/bin/bash

file1="/home/user/scripts/my_public_ip.txt"
file2="/home/user/scripts/mail_my_public_ip.log"
file3="/home/user/scripts/my_public_ip4.txt"

email_addr="receiving-email-address@gmail.com"
command_ipv6="[$(ip addr | grep 'scope global dynamic mngtmpaddr noprefixroute' | awk '{print $2}' | cut -d/ -f1 | head -1)]"

create_file() {
        [[ ! -f $1 ]] && echo "$2" > $1
}

format_email() {
        echo "To: $1"
        echo -e "Subject: "$2"\n\n"
        if ping -4 -c 1 ipinfo.io > /dev/null 2>&1; then echo "$(curl -4 --silent ipinfo.io/ip)" | tee $3; else echo "no ipv4 address obtained"; fi  # ifconfig.me
        echo "$4" | tee $5
}

create_file $file1 "::"
create_file $file3 "0.0.0.0"


if [[ "$(cat $file1)" == "$command_ipv6" ]]; then
        exit 0
elif ping -6 -c 1 smtp.gmail.com > /dev/null; then
        echo -e "IPv6 address is different from \"$file1\"\nSending Email..."
        format_email $email_addr "IP address" $file3 $command_ipv6 $file1 | /usr/bin/msmtp $email_addr  # send email
        echo "Finished running at $(date)"
else
        echo "Ping test failed. Internet connection not established"
        exit 1
fi