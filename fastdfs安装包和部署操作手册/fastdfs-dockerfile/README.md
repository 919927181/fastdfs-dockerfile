# FastDFS Dockerfile local (本地包构建)

本目录包含了docker构建镜像，集群安装帮助手册

1、目录结构
    ./build_image-v6.9.3      fastdfs-v6.0.9版本的构建docker镜像

    ./fastdfs-conf            配置文件，其实和build_image_v.x下的文件是相同的。
       |--setting_conf.sh     设置配置文件的脚本

    ./自定义镜像和安装手册.txt  

    ./qa.txt                  来自于bbs论坛的问题整理：http://bbs.chinaunix.net/forum-240-1.html

	
2、fastdfs 版本安装变化

   + v6.08及以下依赖libevent和libfastcommon两个库，其中libfastcommon是 FastDFS 官方提供的。而v6.09+依赖libfastcommon和libserverframe。
   
   + v6.08及以下适配fastdfs-nginx-module-1.22，v6.09+适配fastdfs-nginx-module-1.23+
   
   + v6.09+ 客户端要使用 fastdfs-client-java 最新版本
   
