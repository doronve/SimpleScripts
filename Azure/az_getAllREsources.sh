#!/bin/bash

#convert to python3

myhome=/var/www/html/all_az_resources.html
tmpfile=$(mktemp /tmp/az_all_rs_XXXX.csv)
echo "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s" > ${tmpfile}
az resource list -o tsv                     >> ${tmpfile}

sed -i 's/	/,/g'                          ${tmpfile}
sed -i 's/.subscriptions.SUBSCRIPTION.resourceGroups//g'  ${tmpfile}
sed -i 's/.......+00:00//g'                    ${tmpfile}

bash GEN/gen_csv_to_html.sh -i ${tmpfile} -o   ${tmpfile}.html
mv ${myhome} ${myhome}_$(date +%s)
mv ${tmpfile}.html ${myhome}

rm -f ${tmpfile}

ls -l ${myhome}*