#!/bin/bash

# to run:
# nohup bash search-domains-for-another_domain.sh &

source="source/domains-verified-sorted.csv"
output="output/domains-with-another_domain.csv"

rm -rf $output
echo "domain,effective_url,has_html_tag,check_for_otherdomain,has_otherdomain" >> $output

check_domain(){
	url="$(echo ${1} | tr -d '\040\011\012\015')"
	effective_url="$(echo ${2} | tr -d '\040\011\012\015')"
	has_html_tag="$(echo ${3} | tr -d '\040\011\012\015')"

	check_for_otherdomain=0
	has_otherdomain=0

	if [ $has_html_tag != 0 ]; then
		curloutput=$(curl -L $url -m 10 --silent -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15")

		curlvars=$(echo "$curloutput" | tail -1)
	
		check_for_otherdomain=1
		has_otherdomain=$(echo "$curloutput" | grep -i "otherdomain\.com" -c)
	fi

	echo " - $url,$effective_url,$has_html_tag,$check_for_otherdomain,$has_otherdomain"
	echo "$url,$effective_url,$has_html_tag,$check_for_otherdomain,$has_otherdomain" >> $output

}

echo "Checking addresses..."
#echo "header,view,address,http_code,url_effective" >> $checkedDomainsFile
while IFS=, read -r header view address http_response effective_url content_type size_download has_html_tag
do
        check_domain "$address" "$effective_url" "$has_html_tag"
done < $source
echo " Done."

echo "See output in $output."
