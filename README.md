# fastdfs-dockerfile

### .项目说明
  感谢余庆大佬开源的FastDFS分布式对象存储系统，github: https://github.com/happyfish100/fastdfs
  
  本仓库用于存储fastdfs离线构建镜像的资源和以docker方式的安装手册
  
  备注：PR 提交了v6.08版本的dockerfile和安装手册，github:  https://github.com/happyfish100/fastdfs/tree/master/docker/dockerfile_local-v6.0.9 
       若没有及时构建新版本的镜像，有需要尝新的同学可参考历史版本的dockerfile 自行构建。

### .目录结构
  |--fastdfs架构剖析（原作者的ppt）
  |--fastdf配置文件参数注解
  |--fastdfs安装包和部署操作手册
      |--fastdht-dockerfile 通常用不着
      |--fastdfs-dockerfile
          |--build_image-v6.9.3 离线构建fastdfs镜像
          |--fastdfs-conf       安装fastdfs用的配置文件，其实和build_image_v.x下的文件是相同的。
               |--setting_conf.sh    设置配置文件参数的脚本
          |--fastdfs安装手册.txt
          |--fastdfs离线构建自定义镜像手册.txt
          |--qa.txt 来自于bbs论坛的问题整理：http://bbs.chinaunix.net/forum-240-1.html
		  
### .fastdfs 版本安装变化

   + v6.08及以下依赖libevent和libfastcommon两个库，其中libfastcommon是 FastDFS 官方提供的。而v6.09+依赖libfastcommon和libserverframe。
   
   + v6.08及以下适配fastdfs-nginx-module-1.22，v6.09+适配fastdfs-nginx-module-1.23+
   
   + v6.09+ 客户端要使用 fastdfs-client-java 最新版本
   
### .稳定版本

    v6.08 ,v6.9.3（latest 未用于生产）
   

### .联系交流
@Author: liyanjing，@E-mail: 284223249@qq.com, @wechat: Sd-LiYanJing