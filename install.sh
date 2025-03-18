#!/bin/bash

##############  代理安装脚本  #################
echo -e ''
echo -e "\033[32m====== pfSense 代理全家桶一键安装脚本 ======\033[0m"
echo -e ''

# 定义颜色变量
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"

# 定义目录变量
ROOT="/usr/local"
BIN_DIR="$ROOT/bin"
WWW_DIR="$ROOT/www"
CONF_DIR="$ROOT/etc"
MODELS_DIR="$ROOT/share/pfSense/menu/"
RC_DIR="$ROOT/etc/rc.d"

# 定义日志函数
log() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# 创建目录
log "$YELLOW" "创建目录..."
mkdir -p "$CONF_DIR/sing-box" "$CONF_DIR/clash" "$CONF_DIR/clash/sub" "$CONF_DIR/clash/ui" "$CONF_DIR/tun2socks" "$CONF_DIR/mosdns" "$CONF_DIR/mosdns/rule" || log "$RED" "目录创建失败！"

# 复制文件
log "$YELLOW" "复制文件..."
log "$YELLOW" "生成菜单..."
log "$YELLOW" "添加权限..."
chmod +x bin/*
chmod +x rc.d/*
cp -f bin/* "$BIN_DIR/" || log "$RED" "bin 文件复制失败！"
cp -f www/* "$WWW_DIR/" || log "$RED" "www 文件复制失败！"
cp -f menu/* "$MODELS_DIR/" || log "$RED" "menu 文件复制失败！"
cp -R -f sub/* "$CONF_DIR/clash/sub/" || log "$RED" "sub 文件复制失败！"
cp -R -f ui/* "$CONF_DIR/clash/ui/" || log "$RED" "ui 文件复制失败！"
cp -R -f rule/* "$CONF_DIR/mosdns/rule" || log "$RED" "rule 文件复制失败！"
cp rc.d/* "$RC_DIR/" || log "$RED" "rc.d 文件复制失败！"
cp geo/* "$CONF_DIR/mosdns/" || log "$RED" "geo 文件复制失败！"
cp geo/* "$CONF_DIR/clash/" || log "$RED" "geo 文件复制失败！"
cp conf/config_mosdns.yaml "$CONF_DIR/mosdns/config.yaml" || log "$RED" "mosdns 配置文件复制失败！"
cp conf/config_clash.yaml "$CONF_DIR/clash/config.yaml" || log "$RED" "clash 配置文件复制失败！"
cp conf/config_sing-box.json "$CONF_DIR/sing-box/config.json" || log "$RED" "sing-box 配置文件复制失败！"
cp conf/config_tun2socks.yaml "$CONF_DIR/tun2socks/config.yaml" || log "$RED" "tun2socks 配置文件复制失败！"

# 安装bash
log "$GREEN" "安装 bash"
pkg install -y bash
log "$GREEN" "bash安装完成！"
echo ""

# 新建订阅程序
log "$YELLOW" "添加订阅程序..."
cat>/usr/bin/sub<<EOF
# 启动clash订阅程序
bash /usr/local/etc/clash/sub/sub.sh
EOF
chmod +x /usr/bin/sub

# 添加服务启动项
log "$YELLOW" "配置服务启动项..."
sysrc singbox_enable="YES"
sysrc mosdns_enable="YES"
sysrc clash_enable="YES"
sysrc tun2socks_enable="YES"
echo ""
log "$GREEN" "注意：请备份/etc/rc.conf文件，以便在系统升级或重置后恢复插件功能。"
echo ""

# 开机启动服务
log "$YELLOW" "开机启动服务..."
log "$GREEN" "请安装shellcmd插件，并添加开机启动命令..."
echo ""

# 显示运行命令
log "$YELLOW" "服务运行命令..."
for service in singbox clash mosdns tun2socks; do
    log "$CYAN" "启动:   service $service start"
    log "$CYAN" "停止:   service $service stop"
    log "$CYAN" "重启:   service $service restart"
    log "$CYAN" "状态:   service $service status"
    echo ""
done

# 完成提示
log "$GREEN" "安装完成，进入Web界面，刷新浏览器，然后导航到服务 > 代理管理菜单进行操作。"
echo ""
