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

# mihomo官方arm64内核，ghproxy加速，适配面板要求的clash_meta文件名
curl -sL -m 60 --retry 3 https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-arm64 -o /tmp/clash_meta 2>/dev/null

if [ -f "/tmp/clash_meta" ]; then
    mv /tmp/clash_meta "$CORE_TARGET_DIR/clash_meta" >/dev/null 2>&1
    chmod +x "$CORE_TARGET_DIR/clash_meta" 2>/dev/null
fi

echo "=== Step 1 completed: OpenClash Meta core ready ==="


# ============ 2. MT7986A CPU频率设置为2.0GHz ============
echo "=== Step 2: Setting CPU frequency to 2.0GHz ==="
sed -i '/"mediatek"\/\*|"mvebu"\/\*/{n; s/.*/\tcpu_freq="2.0GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo
echo "=== Step 2 completed: CPU frequency set to 2.0GHz ==="

# ============ 3. 修改默认WiFi名称（SSID） ============
echo "=== Step 3: Configuring default WiFi settings ==="
# 2.4G: Baili-2.4G, 5G: Baili-5G
sed -i 's/ImmortalWrt-2.4G/Chinajy-2.4G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
sed -i 's/ImmortalWrt-5G/Chinajy-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh 2>/dev/null || true
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
echo "=== Step 5 completed ==="


# ============ 6. 修复登录提示符PS1乱码，永久固定 root@主机名:路径# ============
echo "=== Step 6: Fix login PS1 prompt ==="
mkdir -p files/etc
# 复制原版profile，校验源文件存在再操作
SRC_PROFILE="package/base-files/files/etc/profile"
if [ ! -f "$SRC_PROFILE" ]; then
    echo "ERROR: 源文件 $SRC_PROFILE 不存在，跳过PS1修复"
else
    cp "$SRC_PROFILE" files/etc/profile
    # 关键修复：删除破坏PATH的 Windows 占位符代码 export PATH="%PATH%"
    sed -i '/export PATH="%PATH%"/d' files/etc/profile
    # 精准匹配原版PS1整段删除，避免误删其他esac
    sed -i '/export PS1=\047\\u@\\h:\\w\\\$ \047/,/esac/d' files/etc/profile
    # 插入三shell自适应PS1代码
    cat >> files/etc/profile <<'PS1_FIX'
export ENV=/etc/shinit
# ash路径简写函数，仅定义一次
short_pwd() { pwd | sed -e "s|^$HOME|~|" ; }
if [ -n "$BASH_VERSION" ]; then
    export PS1='\u@\h:\w\$ '
    case "$TERM" in
        xterm*|rxvt*)
            export PS1='\[\e]0;\u@\h: \w\a\]'"$PS1"
        ;;
    esac
elif [ -n "$ZSH_VERSION" ]; then
    export PS1='%n@%m:%~# '
    case "$TERM" in
        xterm*|rxvt*)
            export PS1='%{\e]0;%n@%m: %~\a%}'"$PS1"
        ;;
    esac
else
    export PS1="$USER@$HOSTNAME:$(short_pwd)# "
fi
PS1_FIX
fi
echo "=== Step 6 completed: PS1 prompt fixed ==="


echo ""
echo "============================================"
echo "All DIY Part 2 steps completed successfully!"
echo "============================================"
