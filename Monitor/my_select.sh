#!/bin/bash

psql -d DB  -U USER -h HOST -c \
"select c.bu,c.alias,a.node_name, case when (100-a.percentage_idle) > 100 then 100 else (100-a.percentage_idle) END as cpu_utilization, \
100-b.available*100/b.total as ram_utilization,\
to_char(a.snaptime::timestamp(0), 'DD/MM/YYYY HH24:MI:SS') from cpu a ,free b ,pci_tools_cluster_monitor c \
where (a.cluster_name,a.snaptime) in (select cluster_name,snaptime from last_snaptime) \
and a.cluster_name = b.cluster_name and a.cluster_name = c.cluster_name \
and a.node_name = b.node_name \
and a.snaptime = b.snaptime \
and a.percentage_idle <> -1 \
and b.available <> -1 \
and c.alias in (${cls_num_list.collect{"'" + it + "'"}.join(",")}) \
group by 1,2,3,4,5,6 order by 1,4,5,2,3,6\"
