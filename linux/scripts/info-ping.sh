#!/usr/bin/env bash

websites=(
	# Google
	'google.com' 'gmail.com' 'drive.google.com' \

	# Microsoft
	'bing.com' 'outlook.live.com' 'onedrive.live.com' \

	# Shopping
	'amazon.in' 'flipkart.com' \

	# Social
	'twitter.com' 'reddit.com' 'quora.com' \
	'facebook.com' 'instagram.com' 'whatsapp.com' \

	# Video Streaming
	'netflix.com' 'zoom.us' 'youtube.com' \

	# ISP
	'jio.com' 'airtel.in' 'myvi.in' \
)

count='-c5'
interval='-i1'

echo "ping settings: $count $interval "

for i in "${websites[@]}"; do
	printf "\n$i\n"
	(command ping "$count" "$interval" "$i") | (command grep -i '^5 packets transmitted')
done
