# 一键刷机脚本 (One-Click Flash Script)
## FlashToBrick.RiskItAll-Flash

**⚠警告 / WARNING**: 这是一个实验性脚本。可能导致设备变砖。请谨慎使用！  
**This is an experimental script. Improper use may brick your device. Use with extreme caution!**

---

## 📖 简介 / Introduction
这是一个用于在 Android 设备的 Bootloader 和 Fastbootd 模式下自动化刷写分区镜像的 Bash 脚本。  
This is a Bash script for automating the flashing of partition images in both Bootloader and Fastbootd modes on Android devices.

---

## 🔧 功能特性 / Features
- 自动刷写分区列表中的镜像到a/b两个槽位/逻辑分区  
- 刷写进度显示：显示彩色化的刷写进度和状态

---

## ⚠ 重要注意事项 / Important Notes
- **🔒 AVB 未禁用**: 此脚本不会禁用 Android 验证启动 (AVB)。刷写 vbmeta 时请自行更改使用 `--disable-verification` 等参数  
- **📱 设备适配**: 脚本内的默认分区列表基于特定设备，使用前必须根据您自身的设备分区表进行修改  
- **💾 数据清除**: 此操作会清除设备上的所有用户数据  
- **⚡ 电量要求**: 确保设备电量充足（>50%）  

---

## 📦 要求 / Requirements
**已解锁 Bootloader / Unlocked bootloader**  
**Fastboot 访问权限 / Fastboot access**  
**正确的 USB 驱动 / Proper USB drivers**  
**充足的电量 (>50%) / Adequate battery (>50%)**  
**· 💾 Data Wipe: This process will erase all user data on your device.**
---

## 🛠️ 配置与使用 / Configuration & Usage

### 1. 准备工作 / Preparation
- 将设备启动到 fastboot 模式并连接到电脑  
- 将所需镜像文件放入指定目录（默认为 `images`）  

### 2. 配置分区列表 / Configure Partition Lists
根据您的设备修改脚本中的以下列表：
Modify the following lists in the script according to your device:

**🔹 parts 列表（在 bootloader 模式下刷写 / parts list (flashing in bootloader mode)**

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
parts="xbl xbl_config xbl_ramdump abl hyp aop aop_config tz devcfg qupfw uefisecapp imagefv keymaster shrm cpucp dsp featenabler uefi oplusstanvbk engineering_cdt modem bluetooth dtbo splash oplus_sec recovery init_boot boot vendor_boot"
```

**🔹 cows 列表（fastbootd 模式下清理临时分区 / cows list (cleaning temporary partitions in fastbootd mode)**

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
cows="system system_dlkm system_ext vendor vendor_dlkm product odm my_product my_bigball my_carrier my_engineering my_heytap my_manifest my_region my_stock my_company my_preload"
```

**🔹 logical 列表（在 fastbootd 模式下刷写逻辑分区 / logical list (flashing logical partitions in fastbootd mode)**

```bash
# 默认列表（请根据您的设备修改） / Default list (modify according to your device)
logical="my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock odm product system system_dlkm system_ext vendor vendor_dlkm"
```

**🔹 资源目录 / Image directory**

```bash
# 默认设置为 "images"（脚本同目录下的 images 文件夹） / Default is "images" (images folder in the same directory as script)
imgs="images"

# 示例: 如果镜像文件与脚本在同一目录，可设置为 / Example: if image files are in the same directory as script, set to
# imgs="."
```

**🔹 手动添加 AVB 禁用参数（如需） / Manually add AVB disable parameters (if needed)**

在脚本第 115 行附近找到以下代码，自行添加禁用avb验证命令：
Locate the following code around line 115 in the script, and add AVB disable commands manually:

```bash
# 原代码 / Original code:
run "fastboot flash ${p}_a $plash" "${SR} ${C}${p}_a${NC}->${p}.img ${P}[${s_human}]${NC}" "$C_COUNT"
```

3. **执行脚本 / Execute the Script**

```bash
chmod +x FlashToBrick.sh
./FlashToBrick.sh
```

---

**📝 免责声明 / Disclaimer**

**This script is provided as-is without warranty. Use at your own risk. Always verify partition compatibility with your specific device before flashing. Author is not responsible for any device damage or data loss.
此脚本按"原样"提供，作者不承担任何明示或暗示的担保，使用此脚本造成的任何设备损坏、数据丢失或其他问题，作者概不负责。**
