#!/bin/bash
#
# Name: k8s_get_all_status_short.sh
#

myhomefile=/var/www/html/myhome_k8s_short.html

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>AIA - List of K8S Clusters</title>
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
' > ${myhomefile}.new

echo "created on $(date)" >> ${myhomefile}.new

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Num</th>
<th>Link</th>
<th>OS</th>
<th>CPU</th>
<th>Memory</th>
<th>version</th>
<th>namespaces</th>
<th>nodes</th>
<th>Locations</th>
</tr>
</thead>
<tbody>
' >> ${myhomefile}.new 
#<th>upstream</th>

let i=0
#---
for k8shost in $(cat /BD/Monitor/K8S_Hosts*.lst | sort -u | grep -x -v -f /BD/Monitor/nodeexeptions.lst)
do
  let i=${i}+1
  echo "<tr>" >> ${myhomefile}.new
  echo "<td>${i}</td>" >> ${myhomefile}.new
  echo "<td><a href=\"http://${k8shost}:30000\" target=\"_blank\">${k8shost}</a></td>"  >> ${myhomefile}.new
  echo "<td>$(bash GEN/gen_get_os.sh            $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash GEN/gen_get_vm_cpu.sh        $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash GEN/gen_get_vm_mem.sh        $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash K8S/k8s_get_version.sh       $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash K8S/k8s_get_namespaces.sh -k $k8shost)</td>"                        >> ${myhomefile}.new
# echo "<td>$(bash K8S/k8s_get_upstream.sh      $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash K8S/k8s_get_nodes.sh         $k8shost)</td>"                        >> ${myhomefile}.new
  echo "<td>$(bash GEN/get_env_type.sh          $k8shost)</td>"                        >> ${myhomefile}.new
  echo "</tr>" >> ${myhomefile}.new
done

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new
sed -i 's/Running/<b><font color="green">Running<\/font><\/b>/g'                            ${myhomefile}.new
sed -i 's/Completed/<b><font color="green">Completed<\/font><\/b>/g'                        ${myhomefile}.new
sed -i 's/Pending/<b><font color="orange">Pending<\/font><\/b>/g'                           ${myhomefile}.new
sed -i 's/ContainerCreating/<b><font color="orange">ContainerCreating<\/font><\/b>/g'       ${myhomefile}.new
sed -i 's/Evicted/<b><font color="orange">Evicted<\/font><\/b>/g'                           ${myhomefile}.new
sed -i 's/Init:0/<b><font color="orange">Init:0<\/font><\/b>/g'                           ${myhomefile}.new
sed -i 's/Init:CrashLoopBackOff/<b><font color="red">Init:CrashLoopBackOff<\/font><\/b>/g'  ${myhomefile}.new
sed -i 's/CrashLoopBackOff/<b><font color="red">CrashLoopBackOff<\/font><\/b>/g'            ${myhomefile}.new
sed -i 's/ImagePullBackOff/<b><font color="red">ImagePullBackOff<\/font><\/b>/g'            ${myhomefile}.new
sed -i 's/ContainerCannotRun/<b><font color="red">ContainerCannotRun<\/font><\/b>/g'        ${myhomefile}.new
sed -i 's/Init:Error/<b><font color="red">Init:Error<\/font><\/b>/g'                        ${myhomefile}.new
sed -i 's/ Error /<b><font color="red"> Error <\/font><\/b>/g'                              ${myhomefile}.new
sed -i 's/ErrImagePull/<b><font color="red">ErrImagePull<\/font><\/b>/g'                    ${myhomefile}.new

mv $myhomefile ${myhomefile}.$(date +%Y%m%d_%H%M%S)
mv -f ${myhomefile}.new $myhomefile
