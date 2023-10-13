#!/bin/bash

# to run:
# nohup bash search-domains-for-fontname.sh &

source="source/domains-verified-sorted.csv"
output="output/domains-with-fontname.csv"
outputcsslist="output/stylesheets.csv"

rm -rf $output
echo "domain,effective_url,has_html_tag,check_for_fontname,has_fontname" >> $output

rm -rf $outputcsslist
echo "domain,effective_url,css_path" >> $outputcsslist

check_domain(){
	url="$(echo ${1} | tr -d '\040\011\012\015')"
	effective_url="$(echo ${2} | tr -d '\040\011\012\015')"
	has_html_tag="$(echo ${3} | tr -d '\040\011\012\015')"

	check_for_fontname=0
	has_fontname=0

	if [ $has_html_tag != 0 ]; then
		curloutput=$(curl -L $url -m 10 --silent -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15")

		curlvars=$(echo "$curloutput" | tail -1)
	
		check_for_fontname=1
		has_fontname=$(echo "$curloutput" | grep -i "fontname" -c)

		if [ $has_fontname == 0 ]; then
			links=$(grep -ioE "<link rel=('|\")stylesheet[^>]+>" <<< $curloutput)
			for link in "${links[@]}"
			do
				paths=$(grep -iEo "href=('|\")[^'\"]+('|\")" <<< $link)
			
				# replace all single quotes with doubles
				replace="'"
				replacewith="\""
				paths=$(echo "${paths//${replace}/${replacewith}}")

				# get rid of href="	
				replace="href=\""
				replacewith=""
				paths=$(echo "${paths//${replace}/${replacewith}}")

				# get rid of "
				replace="\""
				replacewith=""
				paths=$(echo "${paths//${replace}/${replacewith}}")

				# make paths into an array
				SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
				IFS=$'\n'      # Change IFS to newline char
				paths=($paths) # split the `names` string into an array by the same name
				IFS=$SAVEIFS   # Restore original IFS

				for path in "${paths[@]}"
				do
					echo "PATH $path"
					echo "$url,$effective_url,$path" >> $outputcsslist
				done
			done
		fi

	fi

	echo " - $url,$effective_url,$has_html_tag,$check_for_fontname,$has_"fontname
	echo "$url,$effective_url,$has_html_tag,$check_for_fontname,$has_fontname" >> $output

}

echo "Checking addresses..."
#echo "header,view,address,http_code,url_effective" >> $checkedDomainsFile
while IFS=, read -r header view address http_response effective_url content_type size_download has_html_tag
do
        check_domain "$address" "$effective_url" "$has_html_tag"
done < $source
echo " Done."

echo "See output in $output. Copy $outputcsslist to source dir and run search-stylesheets-for-fontname."
