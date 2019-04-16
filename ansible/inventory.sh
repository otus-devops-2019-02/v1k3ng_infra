#!/bin/bash

# получаем значения из gcloud
db_host=`gcloud compute instances list | awk '{print $1}' | grep db`
db_ip=`gcloud compute instances list | awk '{print $1, $5}' | grep db | awk '{print $2}'`
app_host=`gcloud compute instances list | awk '{print $1}' | grep app`
app_ip=`gcloud compute instances list | awk '{print $1, $5}' | grep app | awk '{print $2}'`

# вставляем полученные значения в inventory.json
if [[ $1 == "--list" ]]
then
cat <<EOF > inventory.json
{
    "db": {
        "hosts": ["$db_host"],
        "vars": {
            "ansible_host": "$db_ip"
        }
    },
    "app": {
        "hosts": ["$app_host"],
        "vars": {
            "ansible_host": "$app_ip"
        }
    }
}
EOF
cat inventory.json
fi