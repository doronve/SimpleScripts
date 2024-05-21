select
    a.snaptime,
    a.use_percent,
    a.cluster_name,
    a.ns,
    a.pvc_name,
    to_char(a.snaptime::timestamp(0), 'DD/MM/YYYY HH24:MI:SS')
from
    pvc_usage a,
    pci_tools_cluster_monitor b
where
    a.cluster_name=b.alias
and a.use_percent >= :v1
and b.bu = 'DO'
and a.ns not like 'openshift%'
and a.snaptime >= now() - interval '1 hour'
order by cluster_name;
