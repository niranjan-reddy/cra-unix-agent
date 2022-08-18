#vi /opt/scripts/system-info.sh


# systemInformation
var_hostname=`hostname`
var_uptime=`uptime | awk '{print $3,$4}' | sed 's/,//'`
var_manufacturer=`cat /sys/class/dmi/id/chassis_vendor`
var_productName=`cat /sys/class/dmi/id/product_name`
var_version=`cat /sys/class/dmi/id/product_version`
var_serialNumber=`sudo cat /sys/class/dmi/id/product_serial`
var_machineType=`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
var_systemDetails=""
var_availableRAM=""
var_usageRAM=""
var_operatingSystem=`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
var_osVersion=""
var_osFamily=""
var_kernel=`uname -r`
var_architecture=`arch`
var_processorName=`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
var_activeUser=`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
var_systemMainIp=`hostname -I`


# memory_CPUUsage
var_memoryUsage=`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
var_swapUsage=`free | awk '/Swap/{printf("%.2f%"), $3/$2*100}'`
var_cpuUsage=`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`


# diskUsage
var_usage=`df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'`

# var_filesystem=
# var_size=
# var_used=
# var_avail=
# var_use=
# var_mountedOn=


# wwnDetails
var_wwnDetails=`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "$(hostname) is a VM"; else cat /sys/class/fc_host/host?/port_name; fi`

# Oracle DB Instance
var_oracleDBInstance=`if id oracle >/dev/null 2>&1; then /bin/ps -ef|grep pmon; echo "oracle user does not exist on $(hostname)"; fi`

# Package Updates Status
var_packageUpdate=`if (( $(cat /etc/*-release | grep -w "Oracle|Red Hat|CentOS|Fedora" | wc -l) > 0 )); then yum updateinfo summary | grep 'Security|Bugfix|Enhancement'; else cat /var/lib/update-notifier/updates-available; fi`


echo -e "======================================"
echo -e "Values Go Here....."
echo $var_hostname
echo $var_uptime
echo -e "======================================"

#!/bin/bash
echo -e "-------------------------------System Information----------------------------"
echo -e "Hostname:\t\t"$var_hostname
echo -e "uptime:\t\t\t"$var_uptime
echo -e "Manufacturer:\t\t"$var_manufacturer
echo -e "Product Name:\t\t"$var_productName
echo -e "Version:\t\t"$var_version
echo -e "Serial Number:\t\t"$var_serialNumber
echo -e "Machine Type:\t\t"$var_machineType
echo -e "Operating System:\t"$var_operatingSystem
echo -e "Kernel:\t\t\t"$var_kernel
echo -e "Architecture:\t\t"$var_architecture
echo -e "Processor Name:\t\t"$var_processorName
echo -e "Active User:\t\t"$var_activeUser
echo -e "System Main IP:\t\t"$var_systemMainIp
echo ""
echo -e "-------------------------------CPU/Memory Usage------------------------------"
echo -e "Memory Usage:\t"$var_memoryUsage
echo -e "Swap Usage:\t"$var_swapUsage
echo -e "CPU Usage:\t"$var_cpuUsage
echo ""
echo -e "-------------------------------Disk Usage >80%-------------------------------"
$var_usage
echo ""

echo -e "-------------------------------For WWN Details-------------------------------"
$var_wwnDetails
echo ""

echo -e "-------------------------------Oracle DB Instances---------------------------"
$var_oracleDBInstance

$var_packageUpdate

echo "Done"

###############################################################################################
# Form the JSON Object Here
# var_JSON_Response="${var_JSON_Response} World"

var_JSON_Response='[{
        "systemInformation": {
                "hostname": "$var_hostname",
                "uptime": "$var_uptime",
                "manufacturer": "$var_manufacturer",
                "productName": "$var_productName",
                "version": "$var_version",
                "serialNumber": "$var_serialNumber",
                "machineType": "$var_machineType",
                "operatingSystem": "$var_operatingSystem",
                "kernel": "$var_kernel",
                "architecture": "$var_architecture",
                "processorName": "$var_processorName",
                "activeUser": "$var_activeUser",
                "systemMainIP": "$var_systemMainIp"
        }
},
{
        "memory_CPUUsage": {
                "memoryUsage": "$var_memoryUsage",
                "swapUsage": "$var_swapUsage",
                "cpuUsage": "$var_cpuUsage"
        }
},
{
        "diskUsage": [{
                        "usage": "80%"
                },
                {
                        "$var_usage"
                }
        ]
},
{
        "wwnDetails": "$var_wwnDetails"
}
]'

echo $var_JSON_Response