#!/bin/bash
#------------------------------------------------------
# gen_csv_to_html.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -i <input csv file> -o <output html file> [-t <text>] [-f <text file>]"
  echo "Examples:"
  echo "   $0 -i /tmp/at40mynsrt_pods.csv -o /tmp/mypods.html -t 'some text' -f /path/to/file.txt"
  echo " the text (either from the -t flage and/or from the file) will be added to the header of the html"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------

function get_params() {
export SOMETEXT=""
  while getopts :i:o:t:f: opt; do
    case "$opt" in
    i) INCSVFILE="$OPTARG"   ;;
    o) OUTHTMLFILE="$OPTARG" ;;
    f) FILETEXT="$OPTARG"    ;;
    t) SOMETEXT="$OPTARG"    ;;
    *) Usage ;;
    esac
  done
  [[ -z "${INCSVFILE}"   ]] && echo "Missing Input CSV File Name"      && Usage
  [[ -z "${OUTHTMLFILE}" ]] && echo "Missing Output HTML File Name"    && Usage
  [[ ! -f "${INCSVFILE}" ]] && echo "File ${INCSVFILE} Does not exist" && Usage
  if [ ! -z "${FILETEXT}" ]
  then
    if [ ! -f "${FILETEXT}"  ]
    then
      echo "File ${FILETEXT} Does not exist"  && Usage
    fi
  fi
}
function echoHeaders()
{
echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
'    >> ${OUTHTMLFILE}
echo $* | awk -F, '{for(i=1;i<=NF;i++){printf("<th>%s</th>",$i);}}END{printf("\n")}' >> ${OUTHTMLFILE}
echo '
</tr>
</thead>
<tbody>
'    >> ${OUTHTMLFILE}
}
#
# MAIN
#
#---
get_params $*

echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>AIA - List of OCP Projects</title>
        <script type="text/javascript" src="myhome/JS/jquery-latest.js"></script>
        <script type="text/javascript" src="myhome/JS/__jquery.tablesorter.js"></script>
        <script type="text/javascript" src="myhome/JS/jquery.tablesorter.pager.js"></script>
        <script type="text/javascript" src="myhome/JS/chili-1.8b.js"></script>
        <script type="text/javascript" src="myhome/JS/docs.js"></script>

<script type="text/javascript" id="js">$(document).ready(function() {
        // call the tablesorter plugin
        $("table").tablesorter({
                // sort on the first column and third column, order asc
                sortList: [[0,0],[2,0]]
        });
}); </script>
</head>
' > ${OUTHTMLFILE}

echo "Created on `date`" >> ${OUTHTMLFILE}
echo "</br>" >> ${OUTHTMLFILE}
[[ ! -z "${SOMETEXT}" ]] && echo "${SOMETEXT}" >> ${OUTHTMLFILE}
[[ ! -z "${FILETEXT}" ]] && cat  "${FILETEXT}" >> ${OUTHTMLFILE}
echo "</br>" >> ${OUTHTMLFILE}

HEAD=$(head -n 1 $INCSVFILE)
echoHeaders Seq,$HEAD

awk -F, 'NR>1{
      printf("<tr><td>%d</td>",(NR-1));
      for(i=1;i<=NF;i++) { printf("<td>%s</td>",$i);}
      printf("</tr>\n");
     }' ${INCSVFILE} >> ${OUTHTMLFILE}

echo "
</tbody>
</table>
</html>
" >> ${OUTHTMLFILE}
