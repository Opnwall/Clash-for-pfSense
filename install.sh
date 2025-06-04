#!/bin/bash

echo -e ''
echo -e "\033[32m====== clash for pfSense 代理一键安装脚本 ======\033[0m"
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
MENU_DIR="$ROOT/share/pfSense/menu/"
RC_DIR="$ROOT/etc/rc.d"
RC_CONF="/etc/rc.conf.d/"

# 定义日志函数
log() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# 创建目录
mkdir -p "$CONF_DIR/clash" "$CONF_DIR/mosdns" || log "$RED" "目录创建失败！"

# 复制文件
log "$YELLOW" "复制文件..."
log "$YELLOW" "生成菜单..."
log "$YELLOW" "添加权限..."
chmod +x ./bin/* ./rc.d/*
cp -f bin/* "$BIN_DIR/" || log "$RED" "bin 文件复制失败！"
cp -f www/* "$WWW_DIR/" || log "$RED" "www 文件复制失败！"
cp -f rc.d/* "$RC_DIR/" || log "$RED" "rc.d 文件复制失败！"
cp -f menu/* "$MENU_DIR/" || log "$RED" "menu 文件复制失败！"
cp -f rc.conf/* "$RC_CONF/" || log "$RED" "rc.conf 文件复制失败！"
cp -R -f conf/* "$CONF_DIR/clash/" || log "$RED" "conf 文件复制失败！"
cp -R -f mosdns/* "$CONF_DIR/mosdns/" || log "$RED" "mosdns 文件复制失败！"

# 安装bash
sleep 1
log "$YELLOW" "安装bash..."
if ! pkg info -q bash > /dev/null 2>&1; then
  pkg install -y bash > /dev/null 2>&1
fi

# 安装cron
log "$YELLOW" "安装cron..."
if ! pkg info -q pfSense-pkg-Cron > /dev/null 2>&1; then
  pkg install -y pfSense-pkg-Cron > /dev/null 2>&1
fi

# 安装shellcmd
log "$YELLOW" "安装shellcmd..."
if ! pkg info -q pfSense-pkg-Shellcmd > /dev/null 2>&1; then
  pkg install -y pfSense-pkg-Shellcmd > /dev/null 2>&1
fi

# 新建订阅程序
log "$YELLOW" "添加订阅程序..."
cat>/usr/bin/sub<<EOF
# 启动clash订阅程序
bash /usr/local/etc/clash/sub/sub.sh
EOF
chmod +x /usr/bin/sub

# 生成Tun接口   
log "$YELLOW" "启动clash..."
service clash start > /dev/null 2>&1
echo ""

# 完成提示
sleep 1
log "$GREEN" "Clash代理全家桶安装完毕，请刷新浏览器，导航到VPN > Proxy Suite 修改配置。"
log "$GREEN" "透明代理的详细配置，请参考使用教程。所有配置完成后，重启防火墙，让配置生效。"
echo ""