#!/bin/bash
bash gen_join_csv.sh ../K8S/it-01-au.csv ../K8S/it-02-au.csv > a.csv
bash gen_join_csv.sh a.csv ../K8S/it-03-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-04-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-05-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-06-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-07-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-09-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-01-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-02-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-04-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-05-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-07-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-08-au.csv > b.csv
mv -f b.csv a.csv
bash gen_join_csv.sh a.csv ../K8S/it-ilocpdo408-09-au.csv > b.csv
mv -f b.csv a.csv

echo pod,01,02,c0102,03,c0103,04,c0104,05,c0105,06,c0106,07,c0107,09,c0109,01a,c0101a,02a,c0102a,04a,c0104a,05a,c0105a,07a,c0107a,08a,c0108a,09a > all_envs.csv

awk -F, ' {
printf("%s,%s,",$1,$2);
for(i=3;i<NF;i++){
printf("%s,%s,",$i,($2==$i?"<b><font color='green'>EQ<br></font></b>":"<b><font color='red'>NO<br></font></b>"));
}
printf("\n");
} ' a.csv >> all_envs.csv

bash gen_csv_to_html.sh -i all_envs.csv -o all_envs.html
sudo cp all_envs.html /var/www/html/all_envs.html
