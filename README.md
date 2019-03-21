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

**Добавим ssh-ключ в ssh-agent**
```
ssh-add ~/.ssh/id_rsa.pub
```
**Подключение к bastion**
```
ssh 35.195.232.196.xip.io
ssh 35.195.232.196
```

**Подключение к someinternalhost в одну строку**
```
ssh -A -J 35.195.232.196 ssh 10.132.0.3
```
**Пля подключения по алиасу someinternalhost**
**в файл ~/.ssh/config добавить следующие строки**
```
Host someinternalhost
	HostName 10.132.0.3
	ProxyJump 35.195.232.196 
```
**далее подключаться
```
ssh someinternalhost
```






bastion_IP = 35.195.232.196
someinternalhost_IP = 10.132.0.3
