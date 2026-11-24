#!/bin/bash

mkdir -p "$HOME/scripts"

FILE1="$HOME/scripts/my_public_ip.txt"
FILE2="$HOME/scripts/my_public_ip4.txt"

EMAIL_LIST=(
	"receiving-email-address@gmail.com"
)
IPV6_ADDR="[$(ip addr | grep 'scope global dynamic noprefixroute' | awk '{print $2}' | cut -d/ -f1 | head -1)]"
SERVER_NAME="Name"

create_file() {
	[[ ! -f $1 ]] && echo "$2" > "$1"
}

format_email() {
	echo "To: $1"
	echo -e "Subject: $2\n\n"
	if ping -4 -c 1 ipinfo.io &>/dev/null; then
		echo "$(curl -4 --silent ipinfo.io/ip)" | tee "$3"
	else
		echo "no ipv4 address obtained"
	fi
	echo "$4"
}

fatal() {
	echo "$1" >&2 && exit 1
}

main() {
	create_file "$FILE1" "[::]"
	create_file "$FILE2" "0.0.0.0"

	[[ "$(cat "$FILE1")" == "$IPV6_ADDR" ]] && return 0

	local email
	if ping -6 -c 1 smtp.gmail.com >/dev/null; then
		for email in "${EMAIL_LIST[@]}"; do
			echo "Sending email to $email..."
			format_email \
				"$email" \
				"$SERVER_NAME" \
				"$FILE2" \
				"$IPV6_ADDR" \
			| /usr/bin/msmtp || fatal "msmtp error"
		done
		echo "$IPV6_ADDR" > "$FILE1"
		echo "Finished running at $(date)"
	else
		echo "Ping test failed. Internet connection not established" >&2
		return 1
	fi
}

main "$@"
