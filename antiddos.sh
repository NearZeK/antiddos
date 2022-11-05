#! /bin/bash

file='/var/log/apache2/access.log'
tmplogfile='/root/tmp.txt'

# Lay IP tu Apache access log
tail -fn 1000 $file | head -n 1000 | cut -d " " -f 1 > $tmplogfile

# Day IP vao array
declare ip_array       # Array luu cac ip lay tu trong apache access log
declare ip_array_min    # Array luu cac ip khong trung lap lay tu ip_array
declare ip_black        # Array luu cac ip vi pham rule

# them cac ip co trong access log vao Array ip_array
while read -r line;
do
        ip_array+=($line)
done < $tmplogfile

# Trich xuat IP khong trung lap vao ip_array_min
for ip1 in "${ip_array[@]}"
do
        add=1
        for ip2 in "${ip_array_min[@]}"
        do
                if [[ $ip1 == $ip2 ]]
                then
                        add=0
                        break
                fi
        done
        if [[ $add -eq 1 ]]
        then
                ip_array_min+=($ip1)
        fi
done
#echo "${ip_array_min[*]}"

# Tim kiem IP vi pham luat them vao ip_black
for ip1 in "${ip_array_min[@]}"
do
        count=1
        for ip2 in "${ip_array[@]}"
        do
		if [[ $ip1 == $ip2 ]]
                then
                        ((count++))
                fi
        done
        if [[ $count -gt 700 ]]
        then
                ip_black+=($ip1)
        fi
done
echo "${ip_black[*]}"
iptables -I INPUT -s ${ip_black[*]} -p tcp --dport 80 -j DROP
