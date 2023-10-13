#!/bin/bash

# to run:
# nohup bash search-stylesheets-for-fontname.sh &

source="source/stylesheets.csv"
output="output/stylesheets-with-fontname.csv"

rm -rf $output
echo "domain,effective_url,css_path,has_fontname" >> $output


check(){
	url="$(echo ${1} | tr -d '\040\011\012\015')"
	effective_url="$(echo ${2} | tr -d '\040\011\012\015')"
	css_path="$(echo ${3} | tr -d '\040\011\012\015')"

	has_fontname=0

	[[ $effective_url =~ ((http|https):\/\/([^\/])*\/)(.*) ]]
	effective_url_base="${BASH_REMATCH[1]}"

	# build url to fetch from css_apth
	# if it starts with http, use as
	urltofetch=$url
	if [[ $css_path == http* ]]; then 
		urltofetch=$css_path
	# if it starts with //, add http:
	elif [[ $css_path == //* ]]; then
		urltofetch="http:${css_path}"
	elif [[ $css_path == /* ]]; then
		replace="/"
		replacewith=""
		css_path_without_slash=$(echo "${css_path/${replace}/${replacewith}}")
                urltofetch="${effective_url_base}${css_path_without_slash}"
	# every other value of css_path: effective_url + css_path
	else
		urltofetch="${effective_url_base}${css_path}"
	fi

#	echo "fetching css at $urltofetch"

	curloutput=$(curl -L "$urltofetch" -m 10 --silent -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15")
	
	has_fontname=$(echo "$curloutput" | grep -i "fontname" -c)

#	echo " found fontname: $has_fontname"
	echo "$url,$effective_url,\"$urltofetch\",$has_fontname" >> $output

}

echo "Checking stylesheets..."
# domain,effective_url,css_path
while IFS=, read -r domain effective_url css_path 
do
	check "$domain" "$effective_url" "$css_path"
done < $source
echo " Done."

echo "See output in $output."
