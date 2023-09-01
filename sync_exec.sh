#!/bin/bash

source ./include/YCFile.sh
source ./include/YCLog.sh
source ./include/YCTool.sh
source ./include/YCOS.sh
source ./include/YCNic.sh

mypasswd=""
myuser="" 
mydocker=""
BE_DIR="$(cd "`dirname ${BASH_SOURCE[0]}`"/..; pwd)"
RE_DIR="" 

PORT=22
SSH_LIST=(
    # hop_format: username@ip port container_name, e.g., root@192.168.0.1 22 node_1
    "${myuser}@192.168.211.109 ${PORT} ${mydocker} ${RE_DIR}"
    "${myuser}@192.168.211.110 ${PORT} ${mydocker} ${RE_DIR}"
)

sync_start() {
    # example: cmd="bash megatron/dpdk/remake.sh"
    cmd=""
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd > ${ssh_para[0]}.log 2>&1 &"
    done
}

docker_start() {
    # example: cmd2="bash megatron/examples/pretrain_gpt_distributed_small.sh"
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        cmd1="docker exec -i ${ssh_para[2]} "
        cmd2=""
        echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} ${cmd1} ${cmd2} > ${ssh_para[0]}.log 2>&1 &"
    done
}

sync_stop() {
    echo_info "Terminate program..."
    key_word=""
    cmd="ps -ef|grep ${key_word}|grep -v grep|cut -c 9-16"
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd"
        local mypids=(`sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} $cmd`)
        for mypid in "${mypids[@]}"; do
            echo_info "kill process ${mypid}"
            echo_back "sshpass -p ${mypasswd} ssh ${ssh_para[0]} -p ${ssh_para[1]} sudo kill -9 ${mypid}"
        done
    done
}


sync_one_hop() {
    local bedir=$1
    local info1=$2
    local port1=$3 
    local redir=$4
    if [ ! ${redir} ]; then
        echo_warn "Please specify the remote directory"
        exit 0
    fi
    echo_info "Synchronizing ${bedir} to ${info1}:${port1}:${redir}"
    fswatch -o $bedir | while read f; do rsync --delete -avzhcPe "ssh -p ${port1}" ${bedir} ${info1}:${redir}; done &
    echo_info "Done! (PID: $!)"
}

sync_file() {
    if [ ! ${BE_DIR} ]; then
        echo_warn "Please specify the local directory"
        exit 0
    fi
    if [ ! -d ${BE_DIR} ]; then
        echo_erro "${BE_DIR} does not exist"
        exit 0
    fi
    for ssh_item in "${SSH_LIST[@]}"; do
        local ssh_para=(${ssh_item})
        if (( ${#ssh_para[*]} == 3 )); then
            sync_one_hop ${BE_DIR} ${ssh_para[0]} ${ssh_para[1]} ${ssh_para[3]}
        else
            echo_erro "unsupported format: ${ssh_para}"
        fi
    done
}

show_usage() {
    appname=$0
    echo_info "Usage: ${appname} [command], e.g., ${appname} start"
    echo_info "  start"
    echo_info "  docker"
    echo_info "  file"
    echo_info "  stop"
    echo_info "  -- help                          show help message"
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
    "docker")
        docker_start
        ;;
    "file")
        sync_file
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