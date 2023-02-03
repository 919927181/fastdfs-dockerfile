#!/bin/sh
## 使用fastdfs自带的客户端，删除过期文件

#要删除几天之前的文件
expire_day1=1

#通过fastdfs client 命令删除，则需要设置storage的所属组名、虚拟磁盘目录，示例：/usr/bin/fdfs_delete_file /etc/fdfs/client.conf group1/M00/00/00/oYYBAGKe-OmAZ9NQABY-esN9nNw981.jpg
group_name="group1"

#宿主机storage的上传文件存储目录。
store_path="/data/docker/fastdfs/upload/path0/data"
cd ${store_path} || exit

# fastdfs 文件id示例：group1(组名)/M00(虚拟磁盘路径)/01/44(数据两级目录)/wKgAyVgFk9aAB8hwAA-8Q6_7tHw351.jpg(文件名)
# 注意store_path0 虚拟目录则是M00，如果配置了store_path1则是M01，以此类推。
Mpath="M00"

#若是容器运行的storage 需要设置容器名、容器中的存储目录
storage_dockercontainer_name='storage1_1'

today=`date +%Y%m%d`
log_path=/home/shell/fastdfs_expirefile_del_logs
 if [ ! -d "${log_path}" ]; then
      mkdir -p "${log_path}"
 fi

mode_number=1
function chose_info_print() {
  echo -e "\033[32m fastdfs-storager的过期文件清理，请选择：
  
  [1] 直接 find 过期文件 rm 命令，适用一个group内只有一个storage，针对容器或非容器化运行的storage
  
  [2] 使用fastdfs自带的client，针对非容器化运行的storage
  
  [3] 使用fastdfs自带的client，针对 docker 容器运行的storage\033[0m\033[31m 
  
      # 使用 fastdfs的client 请注意：
      #    需要提前设置client.conf配置文件
      #    store_path0 虚拟目录则是M00，如果配置了store_path1则是M01，以此类推。
      \033[0m"
}

#删除宿主机给定目录下的过期文件
function host_del_expirefile(){

  dir=$1
  expire_day=$2
  CurTime=$(date "+%Y-%m-%d %H:%M:%S")
  echo "正在清理目录：$dir 下的过期文件..."	
  echo "${CurTime} $dir by-find-rm" >>${log_path}/${today}.log
  find $dir -type f -mtime +$expire_day -name "*.*" >>${log_path}/${today}.log
  find $dir -type f -mtime +$expire_day -name "*.*" | xargs rm -rf
  
}


#通过fast client 删除宿主机给定目录下的过期文件
function host_del_expirefile_byfastclient(){

  dir=$1
  expire_day=$2
  CurTime=$(date "+%Y-%m-%d %H:%M:%S")
  echo "host by fast-client, 正在清理目录：$dir 下的过期文件..."	
  echo "${CurTime} $dir by-fastdfs-client" >>${log_path}/${today}.log

  for file_list in `find $dir -type f -mtime +$expire_day -name "*.*" | grep -v "m$" `
  do	
        #echo $file_list /data/fastdfs/upload/path0/data/00/00/rBBkW2KhzFyAOKOlAAANFx_7aSY703.txt
        fid=$(echo $file_list | sed "s#$store_path#$group_name/$Mpath#g")
        echo $file_list $fid >>${log_path}/${today}.log    
        /usr/bin/fdfs_delete_file /etc/fdfs/client.conf $fid >>${log_path}/${today}.log

  done
   
}

#通过fast client 删除docker容器内的给定目录下的过期文件
function docker_del_expirefile_byfastclient(){

  dir=$1
  expire_day=$2
  CurTime=$(date "+%Y-%m-%d %H:%M:%S")
  echo "docker by fast-client, 正在清理目录：$dir 下的过期文件..."	
  echo "${CurTime} $dir by-fastdfs-client" >>${log_path}/${today}.log

  #在当前目录下查找（不含子目录），grep -v 过滤掉以m结尾的文件
  for file_list in `find $dir -type f -mtime +$expire_day -name "*.*" | grep -v "m$" `
  do	
        #echo $file_list /data/fastdfs/upload/path0/data/00/00/rBBkW2KhzFyAOKOlAAANFx_7aSY703.txt
        fid=$(echo $file_list | sed "s#$store_path#$group_name/$Mpath#g")   
        echo $file_list $fid >>${log_path}/${today}.log
        docker exec -d $storage_dockercontainer_name /bin/sh -c "/usr/bin/fdfs_delete_file /etc/fdfs/client.conf $fid"
  done

}


# fastdfs 采用两级目录存储，只有叶子目录下存文件： 
#data
# |--00
#    |--00
#        |--a.txt
#         |--b.txt
#    |--01
# |--01

#遍历目录
function lsdir(){
  local dir=$1
  #echo $list
  
  if [ $mode_number -eq 1 ];then
        #遍历非空的目录
        for list in `find $dir -mindepth 2 -maxdepth 2 -not -empty -type d `
        do	
               del_expirefile $list $expire_day1
            
        done               
  elif [ $mode_number -eq 2 ]; then
        #遍历非空的目录
        for list in `find $dir -mindepth 2 -maxdepth 2 -not -empty -type d `
        do	
               host_del_expirefile_byfastclient $list $expire_day1
            
        done   
  elif [ $mode_number -eq 3 ]; then
         #遍历非空的目录
        for list in `find $dir -mindepth 2 -maxdepth 2 -not -empty -type d `
        do	
               docker_del_expirefile_byfastclient $list $expire_day1
            
        done   
  else 
        echo "error!"
  fi       
  
}


function run(){

  #1.屏幕打印出选择项
  chose_info_print
  
  read -p "please input number 1 to 3: " mode_number
  if [[ ! $mode_number =~ [0-3]+ ]]; then
    echo -e "\033[31merror! the number you input isn't 1 to 3\n\033[0m"
    exit 1
  fi
  
  #2. 选择项，用户确认
  echo -e "\033[31m操作有风险，建议使用客户端程序调用fastdfs的API 进行文件删除操作!\033[0m"
  echo -e "\033[36mstorage所属组名：${group_name}，上传文件存储目录：${store_path}，虚拟目录：${Mpath} \033[0m"
  echo -e "\033[36m若是通过fastdfs自带的client，需要设定组名，存储目录和虚拟目录是否对应 \033[0m"
  echo -e "\033[33m使用此脚本，将会删除 $expire_day1 天之前的所有格式的文件！ \033[0m"
  read -r -p "Are You Sure ? [Y/n] " input
  case $input in
      [yY][eE][sS]|[yY])
          echo -e "\033[32mYes, continue...\033[0m"
          ;; 
      [nN][oO]|[nN])
          exit 1
             ;; 
      *)
          echo -e "\033[31merror! you input isn't yes or no.\n\033[0m"
          exit 1
          ;;
  esac

  #3. 执行
  lsdir ${store_path} 

   echo -e "\033[33m清理完毕，goodby！\033[0m"
}

run
