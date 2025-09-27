#!/bin/sh
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
# 镜像文件所在的目录"." 代表与脚本在同一个目录
imgs="images" 
CG=0
wait_for_device() {
 local mode=$1; local timeout=$2; local success_msg=$3; local fail_msg=$4
log "${DD}${S1}${JR}${mode}${MS} (${CS}: ${timeout}s)..."
local count=0
while [ $count -lt $timeout ]; do
if fastboot devices | grep -q "fastboot"; then
local userspace_status=$(fastboot getvar is-userspace 2>/dev/null | awk '/is-userspace:/ {print $2}')
if [ "$mode" = "fastbootd" ] && [ "$userspace_status" = "yes" ]; then
log "\n${G}✓${success_msg}${NC}"; return 0;
elif [ "$mode" != "fastbootd" ] && [ "$userspace_status" = "no" ]; then
log "\n${G}✓${success_msg}${NC}"; return 0;
fi
fi
printf "."
sleep 1
count=$((count+1))
done
log "\n${R}${fail_msg}${NC}"
return 1
}
L="./flash.log"
echo "$(date)" > $L
T="砖寄脚本"
S="开始" E1=":未检测到" E2="请进入fastboot模式并" D="检测到fastboot" GJ="关键" ML="命令" CX="重新" A1="设置活动为A槽" F1="刷入" F2="刷入vbmeta" R1="重启到" R3="请手动" R4="fastbootd" C1="清理COW" F3="刷入逻辑" R5="重启到" F4="格式化" OK="成功" FAIL="失败" SK="跳过(无此文件)" DEL="删除" CQ="重启" SR="刷入" JJ="检查fastboot设备" BL="bootloader" FQ="分区" JS="解锁" JX="继续" SB="失败" S1="设备" JC="检查" YI="已" DD="等待" MS="模式" WC="错误" CS="超时" ZZ="正在" QR="确认" JO="接受" FJ="操作可能清除所有数据！" JL="请查看被" WE="未" JR="进入" LJ="连接" W="耐心" GE="个" AH="按回车键"
log(){ echo -e "$1"|awk '{gsub(/\033\[[0-9;]*m/,"");gsub(/\033\[[0-9;]*[KG]/,"");print}'>>"$L";echo -e "$1";}
size() {
 #使用 stat -c%s 获取镜像大小 无文件输出0
[ -f "$1" ] && stat -c%s "$1" || echo "0"
}
run() {
    o=$(eval "$1" 2>&1);e=$?;echo "$o">>"$L"
    if [ $e -eq 0 ] && ! echo "$o"|grep -qi "fail\|error\|no such\|cannot";then
        log "${B}$3${NC} $2 ${G}${OK}${NC}";return 0
    else
        echo "${ML}${SB}: $1">>"$L";echo -e "${R}${WC}:${NC}\n$o"
        log "${Y}${SB},${QR}${JX}？(y/n)${NC}";read a
        case $a in [Yy]*) return 0;; *) exit 1;; esac
    fi
}
main() {
log "${G}${T}${NC}"
log "${Y}${AH}${S}${NC}"
read var
log "${B}${NC}${JJ}${LJ}"
fastboot devices | grep -q "fastboot" || {
log "${R}${E1}${S1}${NC}"
log "${Y}${E2}${LJ}${NC}"
exit 1
}
log "${G}✓${D}${S1}${NC}"
log "${B}${NC}${ZZ}${JC}${JS}..."
if fastboot getvar unlocked_critical 2>/dev/null | grep -q "yes"; then
log "${G}✓${GJ}${FQ}${YI}${JS}${NC}"
else
log "${Y}${GJ}${FQ}${WE}${JS}, ${ZZ}${JS}${ML}...${NC}"
log "${R}${JL}${LJ}${S1}${QR}${JS}${FJ}${NC}"
if fastboot flashing unlock_critical; then
log "${G}${JS}${ML}${YI}${JO},${S1}${ZZ}${CQ}...${NC}"
if wait_for_device "bootloader" 120 "${S1}${YI}${CX}${LJ}" "${DD}${CX}${LJ}${CS}"; then
if fastboot getvar unlocked_critical 2>/dev/null | grep -q "yes"; then
log "${G}✓${GJ}${FQ}${YI}${JS}${NC}"
else
log "${JC}${SB}${NC}"
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
log "${B}${NC} ${A1}${FQ}..."
run "fastboot set_active a" "${A1}${FQ}"
log "${Y}${AH}${F4}${NC}"
read var
run "fastboot -w" "${F4}" "-"
log "${B}${NC} ${F1}${FQ}..."
parts="xbl xbl_config xbl_ramdump abl hyp aop aop_config tz devcfg qupfw uefisecapp imagefv keymaster shrm cpucp dsp featenabler uefi oplusstanvbk engineering_cdt modem bluetooth dtbo splash oplus_sec recovery init_boot boot vendor_boot"
for p in $parts; do
plash="$imgs/${p}.img"
if [ -f "$plash" ]; then
s_bytes=$(size "$plash")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_a $plash" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_b $plash" "${SR} ${C}${p}_b${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}-${NC} ${p} ${Y}${SK}${NC}"
fi
done
log "${B}${NC} ${F2}${FQ}..."
for p in "vbmeta" "vbmeta_system" "vbmeta_vendor"; do
plash="$imgs/${p}.img"
if [ -f "$plash" ]; then
s_bytes=$(size "$plash")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_a $plash" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p}_b $plash" "${SR} ${C}${p}_b${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}${NC} ${p} ${Y}${SK}${NC}"
fi
done
# 重启到fastbootd
log "${B}${NC} ${R1}${R4}${MS}..."
run "fastboot reboot fastboot" "${R1}${R4}${MS}"
if ! wait_for_device "fastbootd" 60 "${YI}${JR}" "${DD}${R4}${CS}"; then
log "${R}${R3}${JR}${R4}${NC}"; exit 1;
fi
log "${B}${NC} ${C1}${FQ}..."
cows="system system_dlkm system_ext vendor vendor_dlkm product odm my_product my_bigball my_carrier my_engineering my_heytap my_manifest my_region my_stock my_company my_preload"
for p in $cows; do
run "fastboot delete-logical-partition ${p}_a-cow" "${DEL} ${C}${p}_a-cow${NC}" "-"
run "fastboot delete-logical-partition ${p}_b-cow" "${DEL} ${C}${p}_b-cow${NC}" "-"
done
log "${B}${NC} ${F3}${FQ}..."
logical="my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock odm product system system_dlkm system_ext vendor vendor_dlkm"
for p in $logical; do
plash="$imgs/${p}.img"
if [ -f "$plash" ]; then
s_bytes=$(size "$plash")
s_human=$(fmt_bytes "$s_bytes")
CG=$((CG+1)); C_COUNT=$(printf "%03d" $CG)
run "fastboot flash ${p} $plash" "${SR} ${C}${p}${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
else
log "${B}${NC} ${p} ${Y}${SK}${NC}"
fi
done
log "${G}${OK}${SR}${CG}${GE}${FQ}${NC}"
log "${B}${NC} ${R5}${BL}${MS}..."
run "fastboot reboot bootloader" "${R5}${BL}${MS}"
if ! wait_for_device "bootloader" 60 "${YI}${JR}" "${DD}${BL}${CS}"; then
log "${R}${R3}${JR}${BL}${NC}"; exit 1;
fi
log "${G}${AH}${CQ}${NC}"
read var
run "fastboot reboot" "${CQ}${S1}" "-"
log "${Y}${DD}${W}${NC}"
}
main
