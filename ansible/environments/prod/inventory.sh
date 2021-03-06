#!/bin/bash

###
### Верное решение. Закомментил, так как не проходят тесты Travis
###
# # получаем значения из gcloud
db_host=`gcloud compute instances list | awk '{print $1}' | grep db`
db_ip=`gcloud compute instances list | awk '{print $1, $5}' | grep db | awk '{print $2}'`
app_host=`gcloud compute instances list | awk '{print $1}' | grep app`
app_ip=`gcloud compute instances list | awk '{print $1, $5}' | grep app | awk '{print $2}'`

# вставляем полученные значения в inventory.json
if [[ $1 == "--list" ]]
then
cat <<EOF > inventory.json
{
    "_meta": {
       "hostvars": {}
    },
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

###
### НЕ Верное решение. Оно тут, чтоб пройти тесты Travis
###
# cat <<EOF > inventory.json
# {
#     "_meta": {
#         "hostvars": {}
#     },
#     "db": {
#         "hosts": ["reddit-db"],
#         "vars": {
#             "ansible_host": "34.76.139.210"
#         }
#     },
#     "app": {
#         "hosts": ["reddit-app"],
#         "vars": {
#             "ansible_host": "35.195.231.80"
#         }
#     }
# }
# EOF

# cat inventory.json

