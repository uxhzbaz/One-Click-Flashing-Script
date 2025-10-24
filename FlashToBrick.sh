#!/bin/sh
R='\e[1;31m'; G='\e[1;32m'; Y='\e[1;33m'; C='\e[1;36m'; B='\e[1;34m'; P='\e[1;35m'; NC='\e[0m'
T="砖寄脚本"
S=开始 E1=":无" D=请 DL=独立 FB=fastboot ML=命令 A1=A槽 F2=vbmeta R1=到 R3=手动 R4=fastbootd C1=COW F3=逻辑 F4=格式化 OK=成功 FAIL=失败 TG=跳过 SC=删除 SF=是否(y/N) CQ=重启 SR=刷入 JC=检测 BL=bootloader FQ=分区 JX=继续 SB=失败 S1=设备 YI=已 DD=等待 MS=模式 WC=错误 CS=超时 ZZ=正在 QR=确认 JR=进入 LJ=连接 W=耐心 YJ=依据 WZ=未知 GE=个 AH="按回车键" SK="(无此文件)"
# 镜像文件所在的目录"." 代表与脚本在同一个目录
imgs="images"
L="./flash.log"
#刷写列表
#bootloader模式刷写列表
ps="modem"
#fastbootd刷写列表↓
#独立分区刷写列表 (例如: frp, persist等)如无留空
ns="" #以实际情况修改
#临时分区清理列表
cows="my_bigball my_carrier my_engineering my_heytap my_manifest my_product my_region my_stock odm product system system_dlkm system_ext vendor vendor_dlkm"
fd="odm product system system_dlkm system_ext vendor vendor_dlkm"
fmt_bytes() {
echo "$1" | awk '
function human(x) {
s="BKMGT";
while (x >= 1024 && length(s) > 1) { x /= 1024; s = substr(s, 2); }
return sprintf("%.1f%s", x, substr(s, 1, 1));
}
{print human($1)}'
}
CG=0
sd=0
check_ab() {
    fastboot getvar slot-count 2>&1 | grep -q "slot-count: 2" && sd=1
}
wd(){
 local m=$1 t=$2 s=$3 f=$4 c=0
 log "${DD}${m}${LJ}(${t}s)..."
 while [ $c -lt $t ]; do
  if fastboot devices | grep -q fastboot; then
   log "\n${G}✓${S1}${YI}${LJ}${NC}"
   read -p "${Y}${QR}${S1}${JR}${m}${MS}?${SF}${NC} " a
   [[ "$a" == [Yy]* ]] && { log "${G}✓$s${NC}"; return 0; } || log "${R}${MS}${WC}${NC}"
  fi
  printf "."; sleep 1; c=$((c+1))
 done
 log "\n${R}✗$f${NC}"; return 1
}
#刷写函数
f() {
    local p=$1 s=$2
    local img="$imgs/${p}.img"
    [ -f "$img" ] || { log "${B}-${NC} ${p}${s:+_$s} ${Y}${TG}${SK}${NC}"; return 1; }
    local s_bytes=$(size "$img")
    local s_human=$(fmt_bytes "$s_bytes")
    CG=$((CG+1)); local C_COUNT=$(printf "%03d" $CG)
    run "fastboot flash ${p}${s:+_$s} $img" "${SR} ${C}${p}${s:+_$s}${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
}
fs() {
    local p=$1
    local count_before=$CG
    if [ $sd -eq 1 ]; then
        f "$p" a
        [ $? -eq 0 ] && f "$p" b && CG=$((count_before + 1))
    else
        f "$p" ""
    fi
}
fl(){ 
echo "${JC}${FQ}"
fastboot getvar all 2>&1|awk -v d="${DL}" -v y="${YJ}" -v w="${WZ}" -v r="${R}" -v n="${NC}" '
/partition-(type|size):/&&$3~/^[A-Za-z0-9_-]+$/{N=$3;printf N" "
if(N~/_a$/){B=substr(N,1,length(N)-2);A[B]=1;print y":_a->"B}
else if(N~/_b$/){B=substr(N,1,length(N)-2);C[B]=1;print y":_b->"B}
else{S[N]=1;print y":"d}}
END{for(x in A)if(C[x])J=J x" ";else K=K x"_a "
for(x in C)if(!A[x])K=K x"_b "
for(x in S)if(!A[x]&&!C[x])I=I x" "
print d"="I"\nA/B="J"\n"r w"="K n}'
}
echo "$(date)" > $L
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
        log "${Y}${SB},${QR}${JX}?${SF}${NC}";read a
        case $a in [Yy]*) return 0;; *) exit 1;; esac
    fi
}
main() {
    log "${G}${T}${NC}"
    log "${Y}${AH}${S}${NC}"
    read var
    log "${B}${NC}${JC}${LJ}${S1}"
    if ! wd "bootloader" 1 "${S1}${LJ}${OK}" "${S1}${LJ}${SB}"; then
        log "${Y}${D}${JR}${FB}${MS}${NC}"
        exit 1
    fi
    check_ab
read -p "${Y}${SF}${F4}?${NC}" a
[[ "$a" == [Yy]* ]] && run "fastboot -w" "${F4}" "-" || log "${F4}${SK}"
log "${B}${NC} ${SR}${FQ}..."
for p in $ps; do
    fs "$p"
done
log "${B}${NC} ${SR}${F2}${FQ}..."
for p in "vbmeta" "vbmeta_system" "vbmeta_vendor"; do
    fs "$p"
done
# 重启到fastbootd
log "${B}${NC} ${CQ}${R1}${R4}${MS}..."
run "fastboot reboot fastboot" "${CQ}${R1}${R4}${MS}"
if ! wd "fastbootd" 9 "${YI}${JR}" "${DD}${R4}${CS}"; then
log "${R}${D}${R3}${JR}${R4}${NC}"; exit 1;
fi
log "${B}${NC} ${SC}${C1}${FQ}..."
for p in $cows;do for s in a b;do run "fastboot delete-logical-partition ${p}_${s}-cow" "${SC} ${C}${p}_${s}-cow${NC}" "-";done;done
if [ -n "$ns" ]; then
    log "${B}${NC} ${SR}${DL}${FQ}...${NC}"
    for p in $ns; do
    f "$p" ""
done
fi #如 跳过
log "${B}${NC} ${SR}${F3}${FQ}..."
for p in $fd; do
    fs "$p"
done
log "${G}${OK}${SR}${CG}${GE}${FQ}${NC}"
log "${B}${NC} ${CQ}${R1}${BL}${MS}..."
run "fastboot reboot bootloader" "${CQ}${R1}${BL}${MS}"
if ! wd "bootloader" 9 "${YI}${JR}" "${DD}${BL}${CS}"; then
log "${R}${D}${R3}${JR}${BL}${NC}"; exit 1;
fi
log "${G}${AH}${CQ}${NC}"
read var
run "fastboot reboot" "${CQ}${S1}" "-"
log "${Y}${W}${DD}${NC}"
}
main
