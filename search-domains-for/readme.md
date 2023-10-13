These scripts are designed to check the home page HTML for a specific domain name in the source code, check that source code for a specific font name, and check all of the linked stylesheets for that font name.

search-domains-for-another-domain.sh: Replace 'otherdomain' with your target domaini. Results are written to output/search-domains-for-another-domain.csv.

search-domains-for-fontname.sh: Replace 'fontname' with your target font name. Results are written to ou
tput/search-domains-for-fontname.csv. If the font name is not found, all the linked stylesheets are written to output/stylesheets.csv. Copy output/stylesheets.csv to source/stylesheets.csv.

search-stylesheets-for-fontname.sh: Replace 'fontname' with your target font name. Results are written to ou
tput/search-stylesheets-for-fontname.csv.
