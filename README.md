**一键刷机脚本 (One-Click Flash Script)**
FlashToBrick.RiskItAll-Flash
**⚠警告**：这是一个实验性脚本。可能导致设备变砖。请谨慎使用！

这是一个用于在 Android 设备的 Bootloader 和 Fastbootd 模式下自动化刷写分区镜像的 Bash 脚本。

· 自动刷写分区列表中的镜像到 a 和 b 两个槽位/逻辑分区

· 刷写进度显示： 显示彩色化的刷写进度和状态。

· 详细日志记录： 所有操作均记录到 flash.log 文件中

· ⚠ WARNING: This is an experimental script. Improper use may brick your device. Use with extreme caution!

· 🔒 **AVB 未禁用**: 此脚本不会自动禁用 Android 验证启动 (AVB)。刷写 vbmeta 时请自行使用 --disable-verification 等参数。

· 📱 脚本内的分区列表基于特定设备，使用前必须根据您自身的设备分区表进行修改！

· 💾 数据清除: 此操作会清除设备上的所有用户数据

· ⚠ **Experimental**: This script is untested and is intended solely for **learning and experimentation by advanced users**.  

· 🔒 **AVB NOT Disabled**: This script does NOT automatically disable Android Verified Boot (AVB). You must use parameters like --disable-verification when flashing vbmeta.

· 📱 The partition list in the current script is based on a specific device. You must modify it according to your own device's partition table before use.  

· 💾 Data Wipe: This process will erase all user data on your device.
Requirements / 要求

· **Unlocked bootloader / 已解锁bootloader**

· **Fastboot access / Fastboot访问权限**

· **Proper USB drivers / 正确的USB驱动程序**

· **Adequate battery (>50%) / 充足的电量(>50%)**

**Usage / 使用方法**

1. 准备工作:
   · 将设备启动到 fastboot 模式并连接到电脑。1. Ensure device is in fastboot mode
2. Place required images in images directory / 将所需镜像放入images/imgs="任意"目录下
   · （至关重要） 根据您的设备修改脚本中的 parts 和 cows 分区列表
3. **Execute the script / 执行脚本:**
```bash
chmod +x FlashToBrick.sh
./FlashToBrick.sh
```
**Disclaimer / 免责声明**
This script is provided as-is without warranty. Use at your own risk. Always verify partition compatibility with your specific device before flashing. Author is not responsible for any device damage or data loss.
此脚本按"原样"提供，作者不承担任何明示或暗示的担保，使用此脚本造成的任何设备损坏、数据丢失或其他问题，作者概不负责
