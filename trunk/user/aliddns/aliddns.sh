#!/bin/sh
#copyright by hiboy
D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"
aliddns_enable=`nvram get aliddns_enable`
[ -z $aliddns_enable ] && aliddns_enable=0 && nvram set aliddns_enable=0
aliddns_ttl=`nvram get aliddns_ttl`
[ -z $aliddns_ttl ] && aliddns_ttl="-l :9877 -f 600 -c /etc/storage/ddns_script.sh -skipVerify" && nvram set aliddns_ttl="$aliddns_ttl"
ddnsgo="/tmp/ddnsgo/ddnsgo"
[ ! -d /tmp/ddnsgo ] && mkdir -p /tmp/ddnsgo

aliddns_check () {
if [ "$aliddns_enable" = "1" ] && [ -z "`pidof ddnsgo`" ] ; then
	logger -t "ddns-go" "重新启动"
 aliddns_close
 aliddns_start
fi
if [ "$aliddns_enable" = "0" ] ; then	
aliddns_close				
fi
}

aliddns_keep () {
logger -t "ddns-go" "守护进程启动"
sed -Ei '/ddns-go守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/4 * * * * test -z "\`pidof ddnsgo\`"  && aliddns.sh check & #ddns-go守护进程
OSC
}

kill_ps () {
sleep 20
aliddns_start
}

aliddns_close () {
sed -Ei '/ddns-go守护进程|^$/d' "$F"
killall ddnsgo
killall -9 ddnsgo
sleep 5
[ -z "`pidof ddnsgo`" ] && logger -t "ddns-go" "进程已关闭"
}

aliddns_start () {
if [ "$aliddns_enable" = "0" ] ; then	
aliddns_close				
fi
initconfig
logger -t "ddns-go" "正在启动"
sed -Ei '/ddns-go守护进程|^$/d' "$F"
killall ddnsgo
killall -9 ddnsgo
[ -f /etc/storage/bin/ddnsgo ] && ddnsgo="/etc/storage/bin/ddnsgo"
if [ ! -s "$ddnsgo" ] ; then
logger -t "ddns-go" "未找到$ddnsgo ，开始下载"
curl -L -k -S -o "$ddnsgo" --connect-timeout 10 --retry 3 "https://opt.cn2qq.com/opt-file/ddnsgo"
fi
chmod 777 "$ddnsgo"
ddnsgo_ver="$($ddnsgo -v | sed -n '1p')"
[[ "$($ddnsgo -h 2>&1 | wc -l)" -lt 2 ]] && logger -t "ddns-go" "程序不完整，重新下载" && rm -rf $ddnsgo && kill_ps
eval "$ddnsgo $aliddns_ttl" &
sleep 8
[ ! -z "`pidof ddnsgo`" ] && logger -t "ddns-go" "ddnsgo_$ddnsgo_ver 启动成功"
[ -z "`pidof ddnsgo`" ] && logger -t "ddns-go" "ddnsgo_$ddnsgo_ver 启动失败，20秒后尝试重新启动" && kill_ps
port=$(echo $aliddns_ttl | awk '{print $2}' | awk -F ':' {'print $2'} | tr -d " " )
ipaddr=`nvram get lan_ipaddr`
if [ ! -z "$port" ] ; then
nvram set ddnsgoip="http://${ipaddr}:${port}"
else
nvram set ddnsgoip="http://${ipaddr}:9877"
fi
aliddns_keep
exit 0
}

initconfig () {
if [ ! -s "/etc/storage/ddns_script.sh" ] ; then
cat > "/etc/storage/ddns_script.sh" <<-\EEE
notallowwanaccess: true

EEE
	chmod 755 /etc/storage/ddns_script.sh
fi
}

case $1 in
start)
	aliddns_start &
	;;
check)
	aliddns_check &
	;;
stop)
	aliddns_close &
	;;
keep)
	aliddns_keep
	;;
*)
	aliddns_check &
	;;
esac
