#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# 删除旧的多余源码
rm -rf package/*tmp*

# 1. AdGuardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 2. OpenClash
git clone -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 3. DiskMan磁盘管理
git clone https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman

# 4. AdvancedPlus 文件管理
git clone https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus

# 5. Lucky端口转发
git clone https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# 6. EasyTier异地组网
git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 7. Argon主题
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
