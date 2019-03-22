# Readme homework #6

Для передачи **локального** startup_script команде gcloud нужно добавить опцию
```
--metadata-from-file startup-script=
```
Пример полноценной команды gcloud для создания инстанса и запуска **локального** startup_script. При этом, вы должны находиться в директории, в котрой лежит файл startup_script.sh. Файл startup_script.sh добавлен в github репозиторий.
```
gcloud compute instances create reddit-app \
        --boot-disk-size=10GB \
        --image-family ubuntu-1604-lts \
        --image-project=ubuntu-os-cloud \
        --machine-type=g1-small \
        --tags puma-server \
        --restart-on-failure \
        --metadata-from-file startup-script=./startup_script.sh
```
Основные варианты команды gsutil:
Список bucket'ов:
```
gsutil ls
```
Создать bucket:
```
gsutil mb gs://<bucket_name>
```
Скопировать файл в bucket:
```
gsutil cp <file_name> gs://<bucket_name>
```
Содержимое bucket'а:
```
gsutil ls gs://<bucket_name>
```
Удалить файл из bucket'а:
```
gsutil rm gs://<bucket_name>/<file_name>
```
Удалить bucket:
```
gsutil rb gs://<bucket_name>
```
Для передачи **удаленного** startup_script команде gcloud нужно добавить опцию
```
--metadata startup-script-url=gs://<bucket>/<file>
```
Пример полноценной команды gcloud для создания инстанса и запуска **удаленного** startup_script.
```
gcloud compute instances create reddit-app \
        --boot-disk-size=10GB \
        --image-family ubuntu-1604-lts \
        --image-project=ubuntu-os-cloud \
        --machine-type=g1-small \
        --tags puma-server \
        --restart-on-failure \
        --metadata startup-script-url=gs://v1k3ng_bkt/startup_script.sh
```
Не забудьте поменять **startup-script-url** на свой.

Для удаления правила **default-puma-server** из правил firewall можно воспользоваться командой:
```
gcloud compute firewall-rules delete default-puma-server
```
Для создания правила **default-puma-server** из правил firewall можно воспользоваться командой:
```
gcloud compute firewall-rules create default-puma-server \
        --allow=tcp:9292 \
        --direction=INGRESS \
        --source-ranges=0.0.0.0/0 \
        --network=default \
        --target-tags=puma-server
```

testapp_IP = 35.195.232.196  
testapp_port = 9292


# Readme homework #5

### **В GCP созданы два инстанса:**
**bastion**
* IP 35.195.232.196, 10.132.0.2
* zone europe-west1-b
* f1-micro (1 vCPU, 0.6 GB memory)

**someinternalhost**
* IP 10.132.0.3
* zone europe-west1-b
* f1-micro (1 vCPU, 0.6 GB memory)

На bastion поднят VPN-сервер **pritunl**.
* файл **setupvpn.sh** добавлен в репозиторий
* [https://35.195.232.196.xip.io](https://35.195.232.196.xip.io)
* файл **cloud-bastion.ovpn** для подключения добавлен в репозиторий

### **Подключене с помощью openvpn**
```
sudo openvpn --config cloud-bastion.ovpn
```
### **Подключене по SSH**

Добавим ssh-ключ в ssh-agent
```
ssh-add ~/.ssh/id_rsa.pub
```
Подключение к bastion
```
ssh 35.195.232.196.xip.io
ssh 35.195.232.196
```

Подключение к someinternalhost в одну строку
```
ssh -A -J 35.195.232.196 ssh 10.132.0.3
```
Пля подключения по алиасу someinternalhost
в файл ~/.ssh/config добавить следующие строки
```
Host someinternalhost
	HostName 10.132.0.3
	ProxyJump 35.195.232.196 
```
далее подключаться
```
ssh someinternalhost
```
bastion_IP = 35.195.232.196  
someinternalhost_IP = 10.132.0.3


# Readme homework #4

* Склонирован репозиторий v1k3ng_infra
```
git clone git@github.com:otus-devops-2019-02/v1k3ng_infra.git
```
* Создана ветка play-travis
```
git checkout -b play-travis
```
* Создан файл .github/PULL_REQUEST_TEMPLATE.md
* Создан отдельный канал в slack, добавлена интеграция с github
```
/github subscribe Otus-DevOps-2019-02/<GITHUB_USER>_infra commits:all
```
* Создана интеграция с TravisCI (добавлен файл .travis.yml, настроен slack)
* Токен TravisCI зашифрован
```
gem install travis
travis login --com
travis encrypt "devops-team-otus:<token>#maksim_demenev" --add notifications.slack.rooms --com
```


# Readme homework #3

* В ЛК Otus подключен аккаунт github
* Сделан форк репозитория practice-git
* Репозиторий склонирован на локальную машину
* Создан файл maksim-demenev.txt
* Создан и смерджен PR к основному репозиторию

