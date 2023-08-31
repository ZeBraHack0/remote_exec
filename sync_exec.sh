#!/bin/bash

source ./include/YCFile.sh
source ./include/YCLog.sh
source ./include/YCTool.sh
source ./include/YCOS.sh
source ./include/YCNic.sh

mypasswd=""
myuser="" 

PORT=22
SSH_LIST=(
    # hop_format: username@ip port, e.g., root@192.168.0.1 22
    "${myuser}@192.168.211.109 ${PORT} "
)

sync_start() {
    # example: cmd="bash megatron/dpdk/remake.sh"
    cmd=""
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd > ${ssh_para[0]}.log 2>&1 &"
    done
}

sync_stop() {
    echo_info "Terminate program..."
    key_word=""
    # cmd="ps -aux |grep ${key_word} |grep -v grep|awk '{print '$2'}'"
    # cmd="sudo kill -9 `pgrep ${key_word}`"
    cmd="ps -ef|grep ${key_word}|grep -v grep|cut -c 9-16"
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        echo_info "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd"
        local mypids=`sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd`
        for mypid in "${mypids[@]}"; do
            echo_info "kill process ${mypid}"
            echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} sudo kill -9 ${mypid}"
            # echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd"
        done
    done
}

################################################################
####################    * Main Process *    ####################
################################################################
if (( $# == 0 )); then
    show_usage
    exit 0
fi

if (( $UID == 0 )); then
    echo_erro "Don't run this script as root"
    exit 0
fi

global_choice=${1}
case ${global_choice} in
    "start")
        sync_start
        ;;
    "stop")
        sync_stop
        ;;
    "help")
        show_usage 
        ;;
    *)
        echo_erro "Unrecognized argument!"
        show_usage
        ;;
esac