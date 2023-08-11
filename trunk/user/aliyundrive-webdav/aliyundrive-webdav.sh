#!/bin/sh
upanPath="`df -m | grep /dev/mmcb | grep -E "$(echo $(/usr/bin/find /dev/ -name 'mmcb*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"
[ -z "$upanPath" ] && upanPath="`df -m | grep /dev/sd | grep -E "$(echo $(/usr/bin/find /dev/ -name 'sd*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"
alist="$upanPath/alist/alist"
[ -z "$upanPath" ] && alist="/tmp/alist/alist"
[ -f /etc/storage/bin/alist ] && [ -z "$upanPath" ] && ln -sf /etc/storage/bin/alist /tmp/alist/alist
alist_upanPath=""
etcsize=`expr $(df -k | grep "% /etc" | awk 'NR==1' | awk -F' ' '{print $4}' | tr -d "M" ) + 0`
D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"
Alistjson="/tmp/alist/data/config.json"

alist_restart () {
    alenb=`nvram get aliyundrive_enable`
    [ "$alenb" != "1" ] && stop_ald && exit 0
    logger -t "AList" "重新启动"
    kill_ald
   start_ald
    
}

alist_save () {
datasize="$( du -k /tmp/alist/data/data.db-wal | awk '{print $1}' | tr -d "k" )"
etcsize=`expr $(df -k | grep "% /etc" | awk 'NR==1' | awk -F' ' '{print $4}' | tr -d "M" ) + 0`
upanPath="`df -m | grep /dev/mmcb | grep -E "$(echo $(/usr/bin/find /dev/ -name 'mmcb*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"
[ -z "$upanPath" ] && upanPath="`df -m | grep /dev/sd | grep -E "$(echo $(/usr/bin/find /dev/ -name 'sd*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"

   if [ -s /tmp/alist/data/data.db-wal ] && [ -s /tmp/alist/data/config.json ];then
      cd /tmp/alist
      if [ ! -z "$etcsize" ] && [ ! -z "$datasize" ] ; then 
             tar -cz  -f /tmp/alist_backup.tgz data
             if [ -s /tmp/alist_backup.tgz ] ;then
	        datasize1="$( du -k /tmp/alist_backup.tgz | awk '{print $1}' | tr -d "k" )"
		datasize0="$( du -k /tmp/alist_backup.tgz | awk '{print $1}' | tr -d "k" )"
                datasize1=`expr $datasize1 + 200`
		[ ! -d /tmp/var ] && mkdir -p /tmp/var
		rm -rf /tmp/var/data
	        tar -xzvf /tmp/alist_backup.tgz -C /tmp/var
		eval $(md5sum "/tmp/var/data/config.json" | awk '{print "data1="$1;}') && echo "$data1"
		eval $(md5sum "/tmp/alist/data/config.json" | awk '{print "data2="$1;}') && echo "$data2"
		[ ! -d /etc/storage/alist ] && mkdir -p /etc/storage/alist
		[ ! -z "$upanPath" ] && [ ! -d "$upanPath/alist" ] && mkdir -p $upanPath/alist
		[ "$data1"x = "$data2"x ] && [ ! -z "$upanPath" ] && [ "$data1"x = "$data2"x ] && cp -rf /tmp/alist_backup.tgz "$upanPath/alist/alist_backup.tgz"
		
		if [ "$etcsize" -gt "$datasize1" ] ;then	
		 [ "$data1"x = "$data2"x ] && cp -rf /tmp/alist_backup.tgz /etc/storage/alist_backup.tgz && rm -rf /etc/storage/alist/alist_backup.tgz && mv -f /tmp/alist_backup.tgz /etc/storage/alist/alist_backup.tgz && [ -s /etc/storage/alist/alist_backup.tgz ] && logger -t "AList" "/etc/storage/alist/alist_backup.tgz配置文件包$datasize0 k 备份完成，当前/etc/storage可用容量 $etcsize k" 
		else
		logger -t "AList" "当前alist备份配置文件包$datasize1 k 超过了/etc/storage $etcsize k 可用容量，无法保存最新配置到闪存！可尝试在alist主页进行备份，然后恢复备份来减少配置文件的大小"
	        fi
		rm -rf /tmp/var/data
	     fi
	     else
            logger -t "AList" "获取alist配置文件$datasize k 和/etc/storage $etcsize k 容量失败，无法备份配置"
      fi
   fi

}

alist_keep () {
logger -t "AList" "守护进程启动"
sed -Ei '/alist守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/1 * * * * test -z "\`pidof alist\`" && test -z "\`pidof aliyundrive-webdav.sh\`" && aliyundrive-webdav.sh restart #alist守护进程"
OSC
sed -Ei '/alist配置备份|^$/d' "$F"
cat >> "$F" <<-OSC
22 */8 * * * aliyundrive-webdav.sh save #alist配置备份"
OSC
}
start_ald() {
sed -Ei '/alist守护进程|^$/d' "$F"
   logger -t "AList" "正在启动..."
    alienable=$(nvram get aliyundrive_enable)
   case "$alienable" in
    1|on|true|yes|enabled)
      cdn=$(nvram get ald_refresh_token)
      db_file=$(nvram get ald_auth_user)
      temp_dir=$(nvram get ald_auth_password)
      bleve_dir=$(nvram get ald_read_buffer_size)
      enable=$(nvram get ald_cache_size)
      name=$(nvram get ald_cache_ttl)
      https_port=$(nvram get ald_host)
      http_port=$(nvram get ald_port)
      token_expires_in=$(nvram get ald_root)
      address=$(nvram get ald_domain_id) 
if [ -z "$upanPath" ] ; then 
   Available_A="$(df -m | grep "% /tmp" | awk 'NR==1' | awk '{print $4}'| tr -d 'M' | cut -f1 -d".")"
   Available_B=$(df -m | grep "% /tmp" | awk 'NR==1' | awk -F' ' '{print $2}'| tr -d 'M' | tr -d '' | cut -f1 -d".")
   Available_B=`expr $Available_B + 20`
   if [ "$Available_A" -lt 10 ];then
   logger -t "AList" "未挂载储存设备，当前/tmp分区$Available_A M较小，临时增加tmp分区容量为$Available_B M"
   mount -t tmpfs -o remount,rw,size="$Available_B"M tmpfs /tmp
   Available_A=$(df -m | grep "% /tmp" | awk 'NR==1' | awk -F' ' '{print $4}')
   echo $Available_A
   Available_A="$(echo "$Available_A" | tr -d 'M' | tr -d '')"
   fi
   tag=$(curl -k --silent "https://api.github.com/repos/lmq8267/alist/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
   [ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 --silent https://api.github.com/repos/lmq8267/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
   [ -z "$tag" ] && tag="$( curl -k --connect-timeout 20 --silent https://api.github.com/repos/lmq8267/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
   [ -z "$tag" ] && tag="$( curl -k --connect-timeout 20 -s https://api.github.com/repos/lmq8267/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
   [ ! -s "$(which curl)" ] && tag="$( wget -T 5 -t 3 --no-check-certificate --output-document=-  https://api.github.com/repos/lmq8267/alist/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/lmq8267/alist/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f96 )"
   [ - L /tmp/alist ] && rm -rf /tmp/alist
   [ ! -d /tmp/alist ] && mkdir -p /tmp/alist
   rm -rf /home/root/data
   rm -rf /home/admin/data
   if [ ! -s /tmp/alist/data/data.db-wal ] || [ ! -s /tmp/alist/data/config.json ] ; then
       rm -rf /tmp/alist/data
   if [ -s /etc/storage/alist/data/data.db-wal ] && [ -s /etc/storage/alist/data/config.json ] ; then
      mv -f /etc/storage/alist/data /tmp/alist/data
   fi
   fi
   if [ ! -s /tmp/alist/data/data.db-wal ] || [ ! -s /tmp/alist/data/config.json ] ; then
       rm -rf /tmp/alist/data
   if [ -s /etc/storage/alist/alist_backup.tgz ] ; then
      tar -xzvf /etc/storage/alist/alist_backup.tgz -C /tmp/alist
   fi
   fi
   if [ ! -s /tmp/alist/data/data.db-wal ] || [ ! -s /tmp/alist/data/config.json ] ; then
       rm -rf /tmp/alist/data
   if [ -s /etc/storage/alist_backup.tgz ] ; then
      tar -xzvf /etc/storage/alist_backup.tgz -C /tmp/alist
   fi
   fi
   [ -L /tmp/alist/data/data ] && rm -rf /tmp/alist/data/data
   ln -sf /tmp/alist/data /home/root/data
   ln -sf /tmp/alist/data /home/admin/data
   chmod 644 /tmp/alist/data/*
config='{
  "force": false,
  "site_url": "",
  "cdn": "'${cdn}'",
  "jwt_secret": "zcML9HKH2ksUV8AK",
  "token_expires_in": '${token_expires_in}',
  "database": {
    "type": "sqlite3",
    "host": "",
    "port": 0,
    "user": "",
    "password": "",
    "name": "",
    "db_file": "'${db_file}'",
    "table_prefix": "x_",
    "ssl_mode": ""
  },
  "scheme": {
    "address": "'${address}'",
    "http_port": '${http_port}',
    "https_port": '${https_port}',
    "force_https": false,
    "cert_file": "",
    "key_file": "",
    "unix_file": "",
    "unix_file_perm": ""
  },
  "temp_dir": "'${temp_dir}'",
  "bleve_dir": "'${bleve_dir}'",
  "log": {
    "enable": '${enable}',
    "name": "'${name}'",
    "max_size": 10,
    "max_backups": 5,
    "max_age": 28,
    "compress": false
  },
  "delayed_start": 0,
  "max_connections": 0,
  "tls_insecure_skip_verify": true
}'
[ ! -f $Alistjson ] && touch $Alistjson
echo "${config}" >${Alistjson}
   down=1
   [ -f /etc/storage/bin/alist ] && [ -z "$upanPath" ] && ln -sf /etc/storage/bin/alist /tmp/alist/alist
   while [ ! -s "$alist" ] ; do
    down=`expr $down + 1`
    logger -t "AList" "未挂载储存设备, 将下载Mini版8M安装在/tmp/alist/alist,当前/tmp分区剩余$Available_A M"
     if [ ! -z "$tag" ] ; then
      logger -t "AList" "获取到最新alist_v$tag,开始下载..."
      [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/MD5.txt  --connect-timeout 10 --retry 3 https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/$tag/MD5.txt
      [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/MD5.txt https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/$tag/MD5.txt
      [ -s "$(which curl)" ] && curl -L -k -S -o  "$alist"  --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/$tag/alist"
      [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$alist" "https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/$tag/alist"
      else
      logger -t "AList" "未获取到最新版,开始下载备用版本alist_v3.25.1..."
      [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/MD5.txt  --connect-timeout 10 --retry 3 https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/3.25.1/MD5.txt
      [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/MD5.txt https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/3.25.1/MD5.txt 
      [ -s "$(which curl)" ] && curl -L -k -S -o  "$alist"  --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/3.25.1/alist"
      [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$alist" "https://fastly.jsdelivr.net/gh/lmq8267/alist@master/install/3.25.1/alist"
      fi
      if [ -s "$alist" ] && [ -s /tmp/alist/MD5.txt ]; then
         alistmd5="$(cat /tmp/alist/MD5.txt)"
         eval $(md5sum "$alist" | awk '{print "MD5_down="$1;}') && echo "$MD5_down"
         if [ "$alistmd5"x = "$MD5_down"x ] ; then
            logger -t "AList" "程序下载完成，MD5匹配，开始安装..."
            chmod 777 "$alist"
          else
            logger -t "AList" "程序下载完成，MD5不匹配，删除..."
            rm -rf "$alist"
            rm -rf /tmp/alist/MD5.txt
         fi
	else
          logger -t "AList" "程序下载不完整，删除..."
            rm -rf "$alist"
            rm -rf /tmp/alist/MD5.txt
      fi
      if [ ! -s "$alist" ] && [ "$Available_A" -gt 17 ]; then
         logger -t "AList" "程序下载失败，尝试下载alist压缩包..."
         if [ ! -z "$tag" ] ; then
         [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/MD5.txt  --connect-timeout 10 --retry 3 https://github.com/lmq8267/alist/releases/download/$tag/MD5.txt
          [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/MD5.txt https://github.com/lmq8267/alist/releases/download/$tag/MD5.txt
          [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/alist.tar.gz  --connect-timeout 10 --retry 3 https://github.com/lmq8267/alist/releases/download/$tag/alist.tar.gz
          [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/alist.tar.gz https://github.com/lmq8267/alist/releases/download/$tag/alist.tar.gz
          else
          [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/MD5.txt  --connect-timeout 10 --retry 3 https://github.com/lmq8267/alist/releases/download/3.25.1/MD5.txt
          [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/MD5.txt https://github.com/lmq8267/alist/releases/download/3.25.1/MD5.txt 
          [ -s "$(which curl)" ] && curl -L -k -S -o  /tmp/alist/alist.tar.gz  --connect-timeout 10 --retry 3 https://github.com/lmq8267/alist/releases/download/3.25.1/alist.tar.gz
          [ ! -s "$(which curl)" ] && wget --no-check-certificate -O /tmp/alist/alist.tar.gz https://github.com/lmq8267/alist/releases/download/3.25.1/alist.tar.gz
         fi
	 if [ -s /tmp/alist/alist.tar.gz ] && [ -s /tmp/alist/MD5.txt ]; then
         alitarmd5="$(cat /tmp/alist/MD5.txt)"
         eval $(md5sum "/tmp/alist/alist.tar.gz" | awk '{print "MD5_downtar="$1;}') && echo "$MD5_downtar"
         if [ "$alitarmd5"x = "$MD5_downtar"x ] ; then
            logger -t "AList" "程序压缩包下载完成，MD5匹配，开始解压..."
            tar -xzvf /tmp/alist/alist.tar.gz -C /tmp/alist
	    rm -rf /tmp/alist/alist.tar.gz
          else
	    tar -xzvf /tmp/alist/alist.tar.gz -C /tmp/alist
            [ ! -s "$alist" ] && logger -t "AList" "程序压缩包下载完成，MD5不匹配，删除..."
            rm -rf /tmp/alist/alist.tar.gz
            rm -rf /tmp/alist/MD5.txt
         fi
       fi
      fi
   [ ! -s "$alist" ] && [ "$down" -gt "5" ] && logger -t "AList" "程序多次下载失败，将于5分钟后再次尝试下载..." && sleep 300 && down=1
   done
   chmod 777 "$alist"
   "$alist" stop
   killall alist
   "$alist" version >/tmp/alist/alist.version
   alist_ver=$(cat /tmp/alist/alist.version | grep -Ew "^Version" | awk '{print $2}')
   [ -z "$alist_ver" ] &&  logger -t "AList" "程序不完整，重新下载..." && rm -rf "$alist" && sleep 10 && alist_down
   [ ! -z "$alist_ver" ] && logger -t "AList" "当前$alist 版本$alist_ver,准备启动"
   if [ ! -f "/tmp/alist/data/data.db" ] ; then
    [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
    rm -rf /tmp/alist/data/admin.account
    "$alist" admin >>/tmp/alist/data/admin.account 2>&1
    user=$(cat /tmp/alist/data/admin.account | grep "username" | awk -F 'username:' '{print $2}' | tr -d " ")
    pass=$(cat /tmp/alist/data/admin.account | grep "password is" | awk -F 'password is:' '{print $2}' | tr -d " ")
    [ -n "$user" ] && logger -t "AList" "检测到首次启动alist，初始用户:$user  初始密码:$pass"
    [ ! -n "$user" ] && logger -t "AList" "检测到首次启动alist，生成初始用户密码失败" && logger -t "AList" "请在控制台输入aliyundrive-webdav.sh admin显示密码"
    fi
    alist_port="$(cat /tmp/alist/data/config.json | grep http_port | awk '{print $2}' | awk 'NR==1 {print $1}' | tr -d "," )"
   [ -z "$alist_port" ] && alist_port="$(cat /tmp/alist/data/config.json | grep port | awk '{print $2}' | awk 'NR==1 {print $1}' | tr -d "," )"
    "$alist" --data /tmp/alist/data server >/tmp/alist/alistserver.txt 2>&1 &
    datasize="$( du -k /tmp/alist/data/data.db-wal | awk '{print $1}' | tr -d "k" )"
    sleep 10
    [ ! -z "$datasize" ] && logger -t "AList" "/etc/storage容量剩余$etcsize k，alist配置文件$datasize k"
 [ ! -z "`pidof alist`" ] && logger -t "AList" "alist主页:`nvram get lan_ipaddr`:$alist_port" && logger -t "AList" "启动成功" && alist_keep
 [ -z "`pidof alist`" ] && logger -t "AList" "主程序启动失败, 10 秒后自动尝试重新启动" && sleep 10 && alist_restart
else
   [ -L "$upanPath/alist/data/data" ] && rm -rf "$upanPath/alist/data/data"
   [ -L "$upanPath/alist/temp/temp" ] && rm -rf "$upanPath/alist/temp/temp"
   [ ! -d "$upanPath/alist/temp" ] && mkdir -p "$upanPath/alist/temp"
   rm -rf /tmp/alist/data /tmp/alist/temp
   rm -rf /home/root/data
   rm -rf /home/admin/data
   if [ ! -s "$upanPath/alist/data/data.db-wal" ] || [ ! -s "$upanPath/alist/data/config.json" ] ; then
   if [ -s "$upanPath/alist/alist_backup.tgz" ] ; then   
      tar -xzvf "$upanPath/alist/alist_backup.tgz" -C "$upanPath/alist"
   fi
   fi
   if [ ! -s "$upanPath/alist/data/data.db-wal" ] || [ ! -s "$upanPath/alist/data/config.json" ] ; then
       rm -rf "$upanPath/alist/data"
   if [ -s /etc/storage/alist/alist_backup.tgz ] ; then
      tar -xzvf /etc/storage/alist/alist_backup.tgz -C "$upanPath/alist"
   fi
   fi
   if [ ! -s "$upanPath/alist/data/data.db-wal" ] || [ ! -s "$upanPath/alist/data/config.json" ] ; then
       rm -rf "$upanPath/alist/data"
   if [ -s /etc/storage/alist_backup.tgz ] ; then
      tar -xzvf /etc/storage/alist_backup.tgz -C "$upanPath/alist"
   fi
   fi
   
   if [ ! -s "$upanPath/alist/data/data.db-wal" ] || [ ! -s "$upanPath/alist/data/config.json" ] ; then
   if [ -s /etc/storage/alist/data/data.db-wal ] || [ -s /etc/storage/alist/data/config.json ] ; then   
      mv -f /etc/storage/alist/data "$upanPath/alist"
   fi
   fi 
   ln -sf "$upanPath/alist/data" /home/root/data
   ln -sf "$upanPath/alist/data" /home/admin/data
   ln -sf "$upanPath/alist" /tmp/alist
   chmod 644 /tmp/alist/data/*
config='{
  "force": false,
  "site_url": "",
  "cdn": "'${cdn}'",
  "jwt_secret": "zcML9HKH2ksUV8AK",
  "token_expires_in": '${token_expires_in}',
  "database": {
    "type": "sqlite3",
    "host": "",
    "port": 0,
    "user": "",
    "password": "",
    "name": "",
    "db_file": "'${db_file}'",
    "table_prefix": "x_",
    "ssl_mode": ""
  },
  "scheme": {
    "address": "'${address}'",
    "http_port": '${http_port}',
    "https_port": '${https_port}',
    "force_https": false,
    "cert_file": "",
    "key_file": "",
    "unix_file": "",
    "unix_file_perm": ""
  },
  "temp_dir": "'${temp_dir}'",
  "bleve_dir": "'${bleve_dir}'",
  "log": {
    "enable": '${enable}',
    "name": "'${name}'",
    "max_size": 10,
    "max_backups": 5,
    "max_age": 28,
    "compress": false
  },
  "delayed_start": 0,
  "max_connections": 0,
  "tls_insecure_skip_verify": true
}'
[ ! -f $Alistjson ] && touch $Alistjson
echo "${config}" >${Alistjson}
   tag=$(curl -k --silent "https://api.github.com/repos/alist-org/alist/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	[ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 --silent https://api.github.com/repos/alist-org/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
	[ -z "$tag" ] && tag="$( curl -k --connect-timeout 20 --silent https://api.github.com/repos/alist-org/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
	[ -z "$tag" ] && tag="$( curl -k --connect-timeout 20 -s https://api.github.com/repos/alist-org/alist/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
	[ ! -s "$(which curl)" ] && tag="$( wget -T 5 -t 3 --no-check-certificate --output-document=-  https://api.github.com/repos/alist-org/alist/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
        [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/alist-org/alist/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f96 )"
    down=1
   while [ ! -s "$alist" ] && [ ! -s "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" ] ; do
      down=`expr $down + 1`
      logger -t "AList" "找不到$alist, 开始下载"
      if [ ! -z "$tag" ] ; then
          logger -t "AList" "获取到最新版本$tag, 开始下载"
          [ -s "$(which curl)" ] && curl -L -k -S -o "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/alist-org/alist/releases/download/$tag/alist-linux-musl-mipsle.tar.gz"
	  [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" "https://github.com/alist-org/alist/releases/download/$tag/alist-linux-musl-mipsle.tar.gz"
	  [ -s "$(which curl)" ] && curl -L -k -S -o "$upanPath/alist/md5.txt" --connect-timeout 10 --retry 3 "https://github.com/alist-org/alist/releases/download/$tag/md5.txt"
	  [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$upanPath/alist/md5.txt" "https://github.com/alist-org/alist/releases/download/$tag/md5.txt"
          else
	  logger -t "AList" "获取到最新版本失败, 开始下载备用版本alist_v3.25.1"
	  [ -s "$(which curl)" ] && curl -L -k -S -o "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/alist-org/alist/releases/download/v3.25.1/alist-linux-musl-mipsle.tar.gz"
	  [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" "https://github.com/alist-org/alist/releases/download/v3.25.1/alist-linux-musl-mipsle.tar.gz"
	  [ -s "$(which curl)" ] && curl -L -k -S -o "$upanPath/alist/md5.txt" --connect-timeout 10 --retry 3 "https://github.com/alist-org/alist/releases/download/v3.25.1/md5.txt"
	  [ ! -s "$(which curl)" ] && wget --no-check-certificate -O "$upanPath/alist/md5.txt" "https://github.com/alist-org/alist/releases/download/v3.25.1/md5.txt"
      fi
   if [ -s "$upanPath/alist/md5.txt" ] && [ -s "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" ] ; then
      aliMD5="$(cat $upanPath/alist/md5.txt | grep musl-mipsle | awk '{print $1}')"
      eval $(md5sum "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" | awk '{print "aliMD5_down="$1;}') && echo "$aliMD5_down"
      if [ "$aliMD5"x = "$aliMD5_down"x ]; then
      logger -t "AList" "安装包下载完成，MD5匹配，开始解压..."
      tar -xzvf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" -C "$upanPath/alist"
      else
      tar -xzvf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" -C "$upanPath/alist"
      [ ! -s "$alist" ] && logger -t "AList" "安装包下载不完整，MD5不匹配，删除重新下载"
      rm -rf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" "$upanPath/alist/md5.txt"
      fi
   fi
   if [ ! -s "$alist" ] ; then
      logger -t "AList" "安装包解压失败，删除重新下载"
      rm -rf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz"
     [ "$down" -gt "5" ] && logger -t "AList" "程序多次下载失败，将于5分钟后再次尝试下载..." && sleep 300 && down=1
   fi
   done
   if [ ! -s "$alist" ] && [ -s "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" ] ; then
      aliMD5="$(cat $upanPath/alist/md5.txt | grep musl-mipsle | awk '{print $1}')"
      eval $(md5sum "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" | awk '{print "aliMD5_down="$1;}') && echo "$aliMD5_down"
      if [ "$aliMD5"x = "$aliMD5_down"x ]; then
      logger -t "AList" "安装包，MD5匹配，开始解压..."
      tar -xzvf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" -C "$upanPath/alist"
      else
      tar -xzvf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" -C "$upanPath/alist"
      [ ! -s "$alist" ] && logger -t "AList" "安装包MD5不匹配，删除重新下载"
      [ ! -s "$alist" ] && rm -rf  "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" "$upanPath/alist/md5.txt"
      fi
   fi
   [ -s "$alist" ] && chmod 777 "$upanPath/alist/alist"
   "$alist" stop
   killall alist
   "$alist" version >/tmp/var/alist.version
   alist_ver=$(cat /tmp/var/alist.version | grep -Ew "^Version" | awk '{print $2}')
   echo "$alist_ver"
   echo "$tag"
  [ -z "$alist_ver" ] &&  logger -t "AList" "程序不完整，重新下载..." && rm -rf "$alist" "$upanPath/alist/alist-linux-musl-mipsle.tar.gz" && sleep 10 && alist_down
   [ ! -z "$alist_ver" ] && logger -t "AList" "当前$alist 版本$alist_ver,准备启动"
   if [ ! -z "$tag" ] && [ ! -z "$alist_ver" ] ; then
      if [ "$tag"x != "$alist_ver"x ] ; then
      alistup=$(nvram get ald_read_only) 
      if [ "$alistup" = "1" ] ; then
         logger -t "AList" "检测到新版本alist-$tag，当前安装版本$alist_ver，开始下载新版本"
	 rm -rf "$upanPath/alist/alist"
         rm -rf "$upanPath/alist/alist-linux-musl-mipsle.tar.gz"
         alist_down
	 else
       logger -t "AList" "检测到新版本alist-$tag，当前安装版本$alist_ver，未启用自动更新，跳过更新"
       fi
      fi
   fi
   chmod 777 "$alist"
   [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
 if [ ! -f "$upanPath/alist/data/data.db" ] ; then
    [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
    rm -rf /tmp/alist/data/admin.account
    "$alist" admin >>/tmp/alist/data/admin.account 2>&1
    user=$(cat /tmp/alist/data/admin.account | grep "username" | awk -F 'username:' '{print $2}' | tr -d " ")
    pass=$(cat /tmp/alist/data/admin.account | grep "password is" | awk -F 'password is:' '{print $2}' | tr -d " ")
    [ -n "$user" ] && logger -t "AList" "检测到首次启动alist，初始用户:$user  初始密码:$pass"
    [ ! -n "$user" ] && logger -t "AList" "检测到首次启动alist，生成初始用户密码失败" && logger -t "AList" "请在控制台输入aliyundrive-webdav.sh admin显示密码"
 fi
 alist_port="$(cat /tmp/alist/data/config.json | grep http_port | awk '{print $2}' | awk 'NR==1 {print $1}' | tr -d "," )"
[ -z "$alist_port" ] && alist_port="$(cat /tmp/alist/data/config.json | grep port | awk '{print $2}' | awk 'NR==1 {print $1}' | tr -d "," )"
 "$alist" start
 datasize="$( du -k /tmp/alist/data/data.db-wal | awk '{print $1}' | tr -d "k" )"
 sleep 10 
 [ ! -z "$datasize" ] && logger -t "AList" "/etc/storage容量剩余$etcsize k，alist配置文件$datasize k"
 [ ! -z "`pidof alist`" ] && logger -t "AList" "alist主页:`nvram get lan_ipaddr`:$alist_port" && logger -t "AList" "启动成功" && alist_keep 
 [ -z "`pidof alist`" ] && logger -t "AList" "主程序启动失败, 10 秒后自动尝试重新启动" && sleep 10 && alist_restart 

fi
exit 0
}
kill_ald() {
	aliyundrive_process=$(pidof alist)
	if [ -n "$aliyundrive_process" ]; then
		logger -t "AList" "关闭进程..."
  $alist stop 
		killall alist >/dev/null 2>&1
		kill -9 "$aliyundrive_process" >/dev/null 2>&1
	fi
}
stop_ald() {
sed -Ei '/alist守护进程|^$/d' "$F"
sed -Ei '/alist配置备份|^$/d' "$F"
alist_save
	kill_ald
	}



case $1 in
start)
       start_ald &
	;;
stop)
	stop_ald &
	;;
restart)
	alist_restart &
	;;
save)
	alist_save
	;;
set)
    cd /tmp/alist
    [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
    echo "alist密码更改为 $2 "
    "$alist" admin set $2
	;;
admin)
    cd /tmp/alist
    [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
    rm -rf /tmp/alist/data/admin.account
    "$alist" admin >>/tmp/alist/data/admin.account 2>&1
    user=$(cat /tmp/alist/data/admin.account | grep "username" | awk -F 'username:' '{print $2}' | tr -d " ")
    pass=$(cat /tmp/alist/data/admin.account | grep "password is" | awk -F 'password is:' '{print $2}' | tr -d " ")
    if [ -z "$pass" ] ; then
    rm -rf /tmp/alist/data/admin.account
    "$alist" admin random >>/tmp/alist/data/admin.account 2>&1
    user=$(cat /tmp/alist/data/admin.account | grep "username" | awk -F 'username:' '{print $2}' | tr -d " " )
    pass=$(cat /tmp/alist/data/admin.account | grep "password" | awk -F 'password:' '{print $2}' | tr -d " " )
    fi
    echo "用户名: $user  密码: $pass"
    [ -n "$user" ] && logger -t "alist" "用户名: $user  密码: $pass"
	;;
*)
	alist_restart
	;;
esac

	alist_restart &
	;;
esac
