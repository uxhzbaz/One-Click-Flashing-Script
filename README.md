# 一键刷机脚本 (One-Click Flash Script)
## FlashToBrick.RiskItAll-Flash

**⚠警告 / WARNING**

**unlock Critical Partitions** **unlock bootloader** **unlock critical partitions**

fastboot模式/fastboot mode
```bash
fastboot oem device-info
```
```
(bootloader) Verity mode: true
(bootloader) Device unlocked: true
(bootloader) Device critical unlocked: true
(bootloader) Charger screen enabled: false
OKAY [  0.001s]
Finished. Total time: 0.001s
```
如果/if**(bootloader) Device critical unlocked: false**/**(bootloader) Device unlocked: false**

刷写分区必定导致设备变砖/Flashing partitions will BRICK the device  
在解锁bootloader后立即使用/Use immediately after unlocking the bootloader
**解锁关键分区/Unlock critical partitions**
```bash
fastboot flashing unlock_critical
```

---

## 📖 简介 / Introduction
这是一个用于在 Android 设备的 Bootloader 和 Fastbootd 模式下自动化刷写分区镜像的 Bash 脚本。  
This is a Bash script for automating the flashing of partition images in both Bootloader and Fastbootd modes on Android devices.

---

## 🔧 功能 / Features
- 自动刷写分区列表中的镜像到a/b两个槽位/逻辑分区
-  Automatically flashes images from the partition list to both slot A/B / logical partitions  
- 显示彩色的刷写进度 / Displays flashing progress in color

---

## ⚠ 注意事项 / Important Notes
- **🔒 AVB未禁用**: 此脚本不会禁用 Android 验证启动 (AVB)。刷写 vbmeta 时请自行更改使用 `--disable-verification` 等参数  
- **📱 设备适配**: 脚本内的默认分区列表基于特定设备，使用前必须根据您自身的设备分区表进行修改  
- **💾 数据清除**: 此操作会清除设备上的所有用户数据**💾 Data Wipe**: This process will erase all user data on your device.
- **⚡ 电量要求**: 确保设备电量充足（>50%）  
## 📦 要求 / Requirements
**已解锁 Bootloader / Unlocked bootloader**  
**Fastboot 访问权限 / Fastboot access**  
**正确的 USB 驱动 / Proper USB drivers**  
**充足的电量 (>50%) / Adequate battery (>50%)**  
---

## 🛠️ 配置与使用 / Configuration & Usage

### 1. 准备工作 / Preparation
- 将设备启动到 fastboot 模式并连接到电脑  
- 将所需镜像文件放入指定目录（默认为 `images`）  

### 2. 配置分区列表 / Configure Partition Lists
根据您的设备修改脚本中的以下列表：
Modify the following lists in the script according to your device:

**parts 列表**（在 bootloader 模式下刷写 / **parts list** (flashing in bootloader mode)

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
parts="init_boot boot vendor_boot"
```

**cows 列表**（fastbootd 模式下清理临时分区 / **cows list** (cleaning temporary partitions in fastbootd mode)

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
cows="system system_dlkm system_ext vendor vendor_dlkm product odm my_product my_bigball my_carrier my_engineering my_heytap my_manifest my_region my_stock my_company my_preload"
```

**logical 列表**（在 fastbootd 模式下刷写逻辑分区 / **logical list** (flashing logical partitions in fastbootd mode)

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
logical="my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock odm product system system_dlkm system_ext vendor vendor_dlkm"
```

**资源目录** / **Image directory**

```bash
# 默认设置为 "images"（脚本同目录下的 images 文件夹） / Default is "images" (images folder in the same directory as script)
imgs="images"

# 示例: 如果镜像文件与脚本在同一目录，可设置为 / Example: if image files are in the same directory as script, set to
# imgs="."
```

**手动添加 AVB 禁用参数（如需） / Manually add AVB disable parameters** (if needed)

在脚本第 97 行附近找到以下代码，自行添加禁用avb验证命令：
Locate the following code around line 97 in the script, and add AVB disable commands manually:

```bash
# 原代码 / Original code:
run "fastboot flash ${p}_a $plash" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
```
## 📜 Script Output Messages

The following English messages for logging and user interaction:
```
T="Brick Risk Script" 
S="Start" E1=":Not detected" E2="Please enter fastboot mode and" D="Detected fastboot" GJ="Critical" ML="Command" CX="Re" A1="Set active to slot A" F1="Flash" F2="Flash vbmeta" R1="Reboot to" R3="Please manually enter" R4="fastbootd" C1="Clean COW" F3="Flash logical" F4="Format" OK="Success" FAIL="Failure" SK="Skip (No such file)" DEL="Delete" CQ="Reboot" SR="Flash" JJ="Check fastboot device" BL="bootloader" FQ="partition" JS="unlock" JX="Continue" SB="Failed" S1="Device" JC="Check" YI="Already" DD="Waiting" MS="mode" WC="Error" CS="Timeout" ZZ="Processing" QR="Confirm" JO="Accepted" FJ="Operation may erase all data!" JL="Please check the connected" WE="Not" JR="Enter" LJ="connect" W="Patient" GE="pieces" AH="Press Enter to"
```
**执行脚本 / Execute the Script**

```bash
chmod +x FlashToBrick.sh
./FlashToBrick.sh
```

---

**📝 免责声明 / Disclaimer**

**This script is provided as-is without warranty. Use at your own risk. Always verify partition compatibility with your specific device before flashing. Author is not responsible for any device damage or data loss.
此脚本按"原样"提供，作者不承担任何明示或暗示的担保，使用此脚本造成的任何设备损坏、数据丢失或其他问题，作者概不负责。**
