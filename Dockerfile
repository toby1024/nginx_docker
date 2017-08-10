FROM  daocloud.io/daocloud/nginx-proxy

#修改时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    #换成163源
    # wget http://mirrors.163.com/.help/sources.list.jessie -O /etc/apt/sources.list && \
    #开启ll快捷命令代替ls -l
    echo "alias ll='ls \$LS_OPTIONS -l'" >> ~/.bashrc && \
    apt-get update && \
    #安装中文字符集zh_CN.UTF-8支持
    apt-get -y install locales && \
    sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=zh_CN.UTF-8 && \
    #安装net-tools
    apt-get -y install net-tools && \
    #安装logrotate rsyslog 日志服务
    apt-get -y install logrotate rsyslog && \
    # 安装sshd服务
    apt-get -y install openssh-server pwgen vim cron curl && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/log/supervisor && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g" /etc/pam.d/sshd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    #编辑/etc/crontab,修改cron.daily启动logrotate的时间
    sed -i 's/^[0-9]\+.*[0-9]\+\(.*\/etc\/cron\.daily.*$\)/59 23\1/g' /etc/crontab && \
    #修改logrotate配置,增加-f参数,强制执行日志切分
    sed  -i '/^\/usr\/sbin\/logrotate/d' /etc/cron.daily/logrotate && \
    echo "/usr/sbin/logrotate -f /etc/logrotate.conf" >> /etc/cron.daily/logrotate && \
    #把cron日志打开
    sed -i 's/#cron\.\*/cron.*/g' /etc/rsyslog.conf && \
    # set ssh user source,为通过ssh进来的shell导出必要的环境变量
    echo "export PATH=${PATH}" >> ${HOME}/.bashrc && \
    echo "export TERM=xterm" >> ~/.bashrc && \
    echo "export LANG=zh_CN.UTF-8" >> ${HOME}/.bashrc && \
    echo "export LANGUAGE=zh_CN.UTF-8" >> ${HOME}/.bashrc && \
    echo "export LC_ALL=zh_CN.UTF-8" >> ${HOME}/.bashrc

#替换原有的proxy.conf
ADD nginx.conf /etc/nginx/
