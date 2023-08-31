# remote_exec

execute and kill programs on multiple servers concurrently and automatically

### start a new program
```shell
bash sync_exec.sh start
```

### kill a program: modify the keyword variable in the script
```shell
bash sync_exec.sh stop
```



### before executing a sudo program

execute sudo commands on the server without typing passwords：

```shell
sudo vi /etc/sudoers
```

add the following line：

```shell
username    ALL=(ALL:ALL) NOPASSWD:ALL
```



### adjust script execution path

add the following line in the begin of your own script

```shell
cd $(dirname $0)
```

