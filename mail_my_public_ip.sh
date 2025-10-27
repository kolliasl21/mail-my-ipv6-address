#!/bin/bash

mkdir -p "$HOME"/scripts

file1="$HOME/scripts/my_public_ip.txt"
file2="$HOME/scripts/my_public_ip4.txt"

email_addr="receiving-email-address@gmail.com"
command_ipv6="[$(ip addr | grep 'scope global dynamic mngtmpaddr \
	noprefixroute' | awk '{print $2}' | cut -d/ -f1 | head -1)]"
server_name="Name"

create_file() {
	[[ ! -f $1 ]] && echo "$2" > "$1"
}

format_email() {
	echo "To: $1"
	echo -e "Subject: ""$2""\n\n"
	ping -4 -c 1 ipinfo.io > /dev/null 2>&1 && \
		echo "$(curl -4 --silent ipinfo.io/ip)" \
		| tee "$3" || echo "no ipv4 address obtained"
	echo "$4" | tee "$5"
}

main() {
	create_file "$file1" "[::]"
	create_file "$file2" "0.0.0.0"

	[[ "$(cat "$file1")" == "$command_ipv6" ]] && exit 0

	if ping -6 -c 1 smtp.gmail.com > /dev/null; then
		echo "Sending Email..."
		format_email \
			"$email_addr" \
			"$server_name" \
			"$file2" \
			"$command_ipv6" \
			"$file1" \
			| /usr/bin/msmtp $email_addr || echo "msmtp error"
		echo "Finished running at $(date)"
	else
		echo "Ping test failed. Internet connection not established" \
			&& exit 1
	fi
}

main "$@"
