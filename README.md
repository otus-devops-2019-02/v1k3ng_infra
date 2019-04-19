# Readme homework #11

Структура:  
 - Роль
   - Плейбук
     - Сценарий
       - Таск

Применение плейбука к хостам осуществляется при помощи
команды **ansible-playbook**.  
**--check** - произвести "пробный прогон" плейбука.  
**--limit** - ограничиваем группу хостов, для которых применить плейбук  
**--tags <tag_name>** - прогнать только те таски, в которых есть этот тег  


**ansible/inventory.sh**  - Файл динамического инвентори. Через **gcloud** грепает по именам инстансов их внешние ip. На выходе выдает json.

Для создания инфраструктуры нужно:  
 - В директории terraform выполнить **terraform apply --auto-approve=true** для создания бакета под бэкенд
 - В директории terraform/{stage, prod} выполнить **terraform apply --auto-approve=true** для создания нужной инфраструктуры
 - В директории ansible выполнить **ansible-playbook site.yml** для установки нужных пакетов, клонирования репозитория и деплоя приложения

Документация по модулям - https://docs.ansible.com/ansible/latest/list_of_all_modules.html  
Документация по циклам в Ansible - https://docs.ansible.com/ansible/latest/playbooks_loops.html


# Readme homework #10

Кратко об ansible:
```
-m # указать, какой модуль использовать
-i # указть файл inventory
-m ping # модуль ping
-m shell # модуль не использует shell, требует ключ -a
-m command # модуль использует shell, требует ключ -a
```
### Задание на странице 14.2
 - Создан скрипт inventory.sh. При запуске с параметром --list он создает файл inventory.json, в котором описывается динамический inventory.
 - Данные (ip и имена хостов) берутся из gcloud. Так как на тестовом стенде travis нет авторизованного в моей консоли gcloud, то в скрипте вся автоматика закомментирована. Оставлена только статика на текущее окружение stage и запись динамического json как в файл inventory.json, так и вывод в stdout (откуда его подхватит ansible).
 - В файле ansible.cfg параметрм inventory нацелен на файл inventory.sh, таким образом, если не указывать принудительно ansible -i inventory.sh, будет по дефолту использован этот inventory. Таким образом, команда **ansible all -m ping** отрботает корректно.
 - Судя по всему, отличия между динамическим и статическим json в том, что в статике все переменные и параметры хостов пишутся непосредственно в тeг этого хоста, а в динамике для оптимизации скорости запросов сделан тег **_meta**, в котором все описывется заранее.


# Readme homework #9

Импорт имеющейся конфигурации в state-файл:  
```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```
Ссылку в одном ресурсе на атрибуты другого тераформ
понимает как зависимость одного ресурса от другого. Это влияет на очередность создания и удаления ресурсов при применении изменений.  
Terraform поддерживает также явную зависимость используя
параметр **depends_on**.

Чтобы начать использовать модули, нам нужно сначала их
загрузить из указанного источника **source**.
```
terraform get
```
### Задание на странице 42:
Для того чтобы вынести state-файл куда-либо из локального backend'а
```
terraform {
  backend "gcs" {
    bucket = "storage-bucket-for-state-v1k3ng"
    prefix = "stage"
  }
}

terraform init
terraform apply
```
В итоге state-файл перенесентся в указанный удаленный backend. Ничего не потеряется. Ниже пример блокировки:
```
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://storage-bucket-for-state-v1k3ng/stage/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        <ID>
  Path:      gs://<bucket_name>/<prefix_name>/default.tflock
  Operation: OperationTypeApply
  Who:       user@host
  Version:   0.11.13
  Created:   2019-04-11 12:23:41.8817071 +0000 UTC
  Info:      


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
```
### Задание на странице 43:
В файл создания инстанса с приложением добавлены провизионеры:
```
  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#Environment=DATABASE_URL=VALUE/Environment=DATABASE_URL=${var.db_internal_ip}/;' /etc/systemd/system/puma.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart puma.service",
    ]
  }
```
Необходимые для деплоя файлы расположены в modules/app/files.  

Добавление workaround-решения вместо IF..THEN.
В модуле app объявлена новая переменная **need_deploy**
```
variable need_deploy {}
```
В файл modules/app/main.tf добавлен null_resource:
```
resource "null_resource" "app" {
  count = "${var.need_deploy == true ? 1 : 0}"

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"
    host = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}" 
  }

  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#Environment=DATABASE_URL=VALUE/Environment=DATABASE_URL=${var.db_internal_ip}/;' /etc/systemd/system/puma.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart puma.service",
    ]
  }  
}
```
Регулировать деплой можно, меняя значение переменной **need_deploy** в файле /{stage, prod}/terraform.tfvars


# Readme homework #8

### Задание на странице 51:
При добавлении ssh-ключей нескольких пользователей такой конструкцией (самой очевидной, на мой взгляд):
```
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
    ssh-keys = "appuser1:${file(var.public_key_path)}"
  }
```
в метаданные проекта попадают ssh-ключи только последнего в списке пользователя.
Если необходимо добавить несколько ключей, можно сделать так:
```
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}"
  }
```
### Задание на странице 52:
После добавления через web-интерфейс в метаданные проекта ssh-ключа пользователя appuser_web, а затем выполнения **terrafom apply**, ssh-ключ appuser_web был удален, вместо него были добавлены ssh-ключи перечисленных в ресурсах terraform пользователей.
### Задание на странице 53:
Создан файл **lb.tf** для описания балансировщика нагрузки. Пытался сделать двумя путями. Не осилил. IP-адрес балансировщика добавлен в output переменную.
### Задание на странице 54:
Создан второй инстанс для балансировщика нагрузки (reddit-app2). IP-адреса обоих инстансов добавлены в output-переменные. Проблемы при создании инстансов методом копипасты будут при больших масштабах. 2-3-5 инстансов еще терпимо, но когда счет пойдет на десятки - код станет плохо читабелен.
### Задание на странице 55:
Для указания количества создаваемых инстансов использован параметр count. Также, он использован для именования инстансов.
Для вывода IP-адресов использована output-переменная типа list.

**main.tf** - главный конфигурационный файл terraform  
**lb.tf** - описание load-balancer  
**outputs.tf** - список выходных переменных  
**variables.tf** - определение переменных  
**terraform.tfvars** - список и заничения переменных  
**terraform.tfstate** - текущее состояние  
**terraform.tfstate.backup** - предыдущее состояние  

### Основы terraform:
 - **terraform init** # инициировать рабочую директорию, загрузить указанные провайдеры
 - **terraform plan** # показать планируемые изменения относительно текущего состояния
 - **terraform apply** # применить изменения
 - **terraform show** # показать текущее состояние
 - **terraform taint** # пометить ресурс для пересоздания
 - **terraform destroy** # пометить ресурс для пересоздания
 - **terraform fmt** # произвести форматирование файлов terraform

Использование count:
```
count        = "2"
```
```
name         = "reddit-app${count.index}"
```

Чтобы получить значение пользовательской
переменной внутри ресурса используется синтаксис:
```
"${var.var_name}".
```

В **main.tf** добавить для валидности:
```
required_version = ">=0.11,<0.12"
```

Установить автодополнение для terraform:
```
terraform -install-autocomplete
```

### Web-ресурсы:
 - https://www.terraform.io/docs/providers/google/index.html


# Readme homework #7

Проверка json-файла для packer на ошибки:
```
packer validate <filename.json>
packer validate -var-file=<file_whith_vars.json> <filename.json>
```
Создание образа из json-файла для packer:
```
packer build <filename.json>
packer build -var-file=<file_whith_vars.json> <filename.json>
```
Работа с gcloud:
```
gcloud compute instances list # список инстансов
gcloud compute instances delete reddit-app # удаление инстанса
gcloud compute images list | grep redd # выборка образа по имени
gcloud compute images delete <image_name> # удаление образа
```
Два варианта создания инстанса из образа, подготовленного packer'ом:
 - Выбрать конкретный образ в проекте:
```
gcloud compute instances create reddit-app \
        --image-project=ubuntu-os-cloud \
        --machine-type=g1-small \
        --tags puma-server \
        --restart-on-failure \
        --image-project=infra-235110 \
        --image=reddit-full-1553758184
```
- Выбрать последний образ в **image family**:
```
gcloud compute instances create reddit-app \
        --machine-type=g1-small \
        --tags puma-server \
        --restart-on-failure \
        --image-family=reddit-full
```


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

