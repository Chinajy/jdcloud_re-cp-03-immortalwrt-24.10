#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ============ 1. OpenClash Meta内核下载 ============
echo "=== Step 1: Downloading OpenClash Meta core for arm64 ==="
CORE_TARGET_DIR="feeds/luci/applications/luci-app-openclash/root/etc/openclash/core"
mkdir -p "$CORE_TARGET_DIR" 2>/dev/null

# 国内镜像静默下载
curl -sL -m 60 --retry 3 https://mirror.ghproxy.com/https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz 2>/dev/null

# 解压，不做前置判断
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
# 匹配/tmp下所有带clash的文件，批量移动到内核目录
find /tmp -maxdepth 1 -type f -name "*clash*" -exec mv {} "$CORE_TARGET_DIR/clash_meta" \; >/dev/null 2>&1
# 赋予执行权限
chmod +x "$CORE_TARGET_DIR/clash_meta" 2>/dev/null

# 清理临时包
rm -rf /tmp/clash.tar.gz 2>/dev/null
echo "=== Step 1 completed: OpenClash Meta core ready ==="

# ============ 2. MT7986A CPU频率设置为2.0GHz ============
echo "=== Step 2: Setting CPU frequency to 2.0GHz ==="
sed -i '/"mediatek"\/\*|"mvebu"\/\*/{n; s/.*/\tcpu_freq="2.0GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo
echo "=== Step 2 completed: CPU frequency set to 2.0GHz ==="

# ============ 3. 修改默认WiFi名称（SSID） ============
echo "=== Step 3: Configuring default WiFi settings ==="
# 2.4G: Baili-2.4G, 5G: Baili-5G
sed -i 's/ImmortalWrt/Baili-2.4G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
sed -i 's/ImmortalWrt_5G/Baili-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
echo "=== Step 3 completed: WiFi SSID configured ==="

# ============ 4. 禁用冲突的USB挂载包 ============
echo "=== Step 4: Removing conflicting mount packages ==="
# 物理删除 automount 防止被依赖拉入
rm -rf package/emortal/automount 2>/dev/null || true
rm -rf feeds/packages/utils/automount 2>/dev/null || true
rm -rf feeds/packages/utils/ntfs3-mount 2>/dev/null || true
echo "=== Step 4 completed: automount / ntfs3-mount removed ==="

# ============ 5. 固件版本标识 ============
echo "=== Step 5: Setting firmware version banner ==="
BUILD_DATE=$(date +"%Y%m%d")
sed -i "/DISTRIB_DESCRIPTION/d" package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='ImmortalWrt 24.10 for Baili AX6000 (Build ${BUILD_DATE})'" >> package/base-files/files/etc/openwrt_release
sed -i "/PRETTY_NAME/d" package/base-files/files/etc/os-release
sed -i "/OPENWRT_RELEASE/d" package/base-files/files/etc/os-release
echo "PRETTY_NAME=\"ImmortalWrt 24.10 for Baili AX6000 (Build ${BUILD_DATE})\"" >> package/base-files/files/etc/os-release
echo "OPENWRT_RELEASE=\"ImmortalWrt 24.10 for Baili AX6000 (Build ${BUILD_DATE})\"" >> package/base-files/files/etc/os-release
sed -i '/ImmortalWrt-798x-24.10 from PadavanOnly/d' package/base-files/files/etc/banner
echo "      ImmortalWrt 24.10 for Baili AX6000" >> package/base-files/files/etc/banner
echo "=== Step 5 completed ==="


# ============ 6. 修复登录提示符PS1乱码，永久固定 root@主机名:路径# ============
echo "=== Step 6: Fix login PS1 prompt ==="
sed -i '/export PS1=/d' package/base-files/files/etc/profile
echo 'export PS1="\u@\h:\w# "' >> package/base-files/files/etc/profile
rm -f package/base-files/files/root/.profile
echo "=== Step 6 completed: PS1 prompt fixed ==="


echo ""
echo "============================================"
echo "All DIY Part 2 steps completed successfully!"
echo "============================================"
