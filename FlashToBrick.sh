#!/system/bin/sh
R='\e[1;31m'; G='\e[1;32m'; Y='\e[1;33m'; C='\e[1;36m'; B='\e[1;34m'; P='\e[1;35m'; NC='\e[0m'
fmt_bytes() {
echo "$1" | awk '
function human(x) {
s="BKMGT";
while (x >= 1024 && length(s) > 1) { x /= 1024; s = substr(s, 2); }
return sprintf("%.1f%s", x, substr(s, 1, 1));
}
{print human($1)}'
}
# 镜像文件所在的目录"." 代表与脚本在同一个目录。
imgs="images" 
CG=0
wait_for_device() {
 local mode=$1; local timeout=$2; local success_msg=$3; local fail_msg=$4
log "等待${SEB}进入${mode}模式 (超时: ${timeout}s)..."
local count=0
while [ $count -lt $timeout ]; do
if fastboot devices | grep -q "fastboot"; then
local userspace_status=$(fastboot getvar is-userspace 2>/dev/null | awk '/is-userspace:/ {print $2}')
if [ "$mode" = "fastbootd" ] && [ "$userspace_status" = "yes" ]; then
log "\n${G}✓ ${success_msg}${NC}"; return 0;
elif [ "$mode" != "fastbootd" ] && [ "$userspace_status" = "no" ]; then
log "\n${G}✓ ${success_msg}${NC}"; return 0;
fi
fi
printf "."
sleep 1
count=$((count+1))
done
log "\n${R}${fail_msg}${NC}"
return 1  # 超时失败
}
L="./flash.log"
echo "$(date)" > $L
T="一键砖寄脚本"
S="按回车键开始" E1="错误: 未检测到设备" E2="请进入fastboot模式并连接USB" E3="错误: 请手动查看" E4="请手动确认并解锁" E5="已解锁bootloader" E6="已启用OEM解锁" D="检测到fastboot设备" GJ="关键" ML="命令" CX="重新连接"
A1="设置活动分区为A槽" A2="已设A槽" F1="刷入分区" F2="刷入vbmeta分区" R1="重启到fastbootd模式" R2="已进入fastbootd模式" R3="请手动进入fastbootd" R4="等待fastbootd超时" C1="清理COW分区" F3="刷入逻辑分区" R5="重启到bootloader模式" R6="等待bootloader超时" R7="请手动进入bootloader" C2="按回车键格式化" F4="格式化" R8="设备正在重启" W="耐心等待" OK="成功" FAIL="失败" SK="跳过(无此文件)" DK="data" DEL="删除" CQ="重启" SR="刷入" JC="检查fastboot设备连接..." BL="bootloader" FQ="分区" JS="解锁" JX="继续" SB="失败" SBE="设备" JC="检查" YI="已"
log() {
echo "$1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" >> $L
echo -e "$1"
}
size() {
 #使用 stat -c%s 获取镜像大小 无文件输出0
[ -f "$1" ] && stat -c%s "$1" || echo "0"
}
run() {
if eval "$1 >> $L 2>&1"; then
log "${B}$3${NC} $2 ${G}${OK}${NC}"
return 0
else
log "${B}$3${NC} $2 ${R}${FAIL}${NC}"
echo "${ML}${SB}: $1" >> $L
log "${Y}${SB}，是否${JX}？(y/n)${NC}"
read answer
case $answer in
# 用户强行继续,允许
[Yy]*) return 0;;
# 用户选择中止, 退出
*) exit 1;;
esac
fi
}
main() {
log "${G}${T}${NC}"
log "${Y}${S}${NC}"
read var
log "${B}[1/10]${NC} ${JC}"
fastboot devices | grep -q "fastboot" || {
log "${R}${E1}${NC}"
log "${Y}${E2}${NC}"
exit 1
}
log "${G}✓ ${D}${NC}"
log "${B}[2/10]${NC} 正在${JC}${JS}..."
if fastboot getvar unlocked_critical 2>/dev/null | grep -q "yes"; then
log "${G}✓ ${GJ}${FQ}已${JS}。${NC}"
else
log "${Y}${GJ}${FQ}未${JS}, 正在发送${JS}${ML}...${NC}"
log "${R}请查看手机屏幕确认${JS}此操作可能清除所有数据！${NC}"
if fastboot flashing unlock_critical; then
log "${G}${JS}${ML}已接受，${SEB}正在${CQ}...${NC}"
if wait_for_device "bootloader" 120 "${SEB}已${CX}" "等待${CX}超时"; then
if fastboot getvar unlocked_critical 2>/dev/null | grep -q "yes"; then
log "${G}✓ ${GJ}${FQ}已${JS}。${NC}"
else
log "${R}状态${JC}${SB}${NC}"
exit 1
fi
else
exit 1
fi
else
log "${R}${JS}${SB}${NC}"
exit 1
fi
fi
log "${B}[3/10]${NC} ${A1}..."
run "fastboot set_active a" "${A1}" "002" && log "${G}✓ ${A2}${NC}"
log "${B}[4/10]${NC} ${F1}..."
parts="xbl xbl_config xbl_ramdump abl hyp aop aop_config tz devcfg qupfw uefisecapp imagefv keymaster shrm cpucp dsp featenabler uefi oplusstanvbk engineering_cdt modem bluetooth dtbo splash oplus_sec recovery init_boot boot vendor_boot"
for p in $parts; do
img_path="$imgs/${p}.img"
if [ -f "$img_path" ]; then
s_bytes=$(size "$img_path")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_a $img_path" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_b $img_path" "${SR} ${C}${p}_b${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}-${NC} ${p} ${Y}${SK}${NC}"
fi
done
log "${B}[5/10]${NC} ${F2}..."
for p in "vbmeta" "vbmeta_system" "vbmeta_vendor"; do
img_path="$imgs/${p}.img"
if [ -f "$img_path" ]; then
s_bytes=$(size "$img_path")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_a $img_path" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_b $img_path" "${SR} ${C}${p}_b${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}${NC} ${p} ${Y}${SK}${NC}"
fi
done
# 重启到fastbootd
log "${B}[6/10]${NC} ${R1}..."
run "fastboot reboot fastboot" "${R1}"
if ! wait_for_device "fastbootd" 60 "${R2}" "${R4}"; then
log "${R}${R3}${NC}"; exit 1;
fi
log "${B}[7/10]${NC} ${C1}..."
cows="system system_dlkm system_ext vendor vendor_dlkm product odm my_product my_bigball my_carrier my_engineering my_heytap my_manifest my_region my_stock my_company my_preload"
for p in $cows; do
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot delete-logical-partition ${p}_a-cow" "${DEL} ${C}${p}_a-cow${NC}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot delete-logical-partition ${p}_b-cow" "${DEL} ${C}${p}_b-cow${NC}" "$C_COUNT"
done
log "${B}[8/10]${NC} ${F3}..."
logical="my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock odm product system system_dlkm system_ext vendor vendor_dlkm"
for p in $logical; do
img_path="$imgs/${p}.img"
if [ -f "$img_path" ]; then
s_bytes=$(size "$img_path")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p} $img_path" "${SR} ${C}${p}${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}${NC} ${p} ${Y}${SK}${NC}"
fi
done
log "${G}${OK}${SR}${CG} 个${FQ}${NC}"
log "${B}[9/10]${NC} ${R5}..."
run "fastboot reboot bootloader" "${R5}"
if ! wait_for_device "bootloader" 60 "${R2}" "${R6}"; then
log "${R}${R7}${NC}"; exit 1;
fi
log "${Y}${C2}${NC}"
read var
log "${B}[10/10]${NC} ${F4}..."
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot erase userdata" "${F4}user${DK}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot erase metadata" "${F4}meta${DK}" "$C_COUNT"
log "${G}✓${R8}${NC}"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot reboot" "${CQ}${SBE}" "$C_COUNT"
log "${Y}${W}${NC}"
}
main