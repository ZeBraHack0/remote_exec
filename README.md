# remote_exec

execute, log, and kill programs and sync files on multiple servers concurrently and automatically

### setup

fill in the following local variables in the script according to your requirement:

- myuser: your username in the server
- mypasswd: your password for ssh access
- mydocker: your docker name to access
- SSH_LIST: your server list
- cmd: your commands to execute on remote servers
- key_word: keywords to grep your pids to kill 
- RE_DIR: remote directory to sync your file

### start a new program
```shell
bash sync_exec.sh start
```

### start a new program in dockers

```shell
bash sync_exec.sh docker
```

### kill a program: modify the keyword variable in the script

```shell
bash sync_exec.sh stop
```

### sync files from local directory to remote directories

```shell
bash sync_exec.sh file
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

add the following line in the beginning of your own script if necessary

```shell
cd $(dirname $0)
```

