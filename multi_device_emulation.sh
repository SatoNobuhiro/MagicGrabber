#!/bin/bash
#Copyright (c) 2023 Sato Nobuhiro
#All rights reserved.
#Redistribution of this software in any form without permission from the rights holder is not permitted.
#IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

case "$1" in
start)
        #必要となるカーネルモジュールをインポート
        modprobe libcomposite

        #USBガジェットの作成
        mkdir /sys/kernel/config/usb_gadget/multiDeskBoard
        cd /sys/kernel/config/usb_gadget/multiDeskBoard

        #どのようなUSBデバイスとして見せるかの設定
        echo 0x1d6b > idVendor    #Linux Foundation
        echo 0x0104 > idProduct   #Multifunction Composite Gadget
        echo 0x0100 > bcdDevice   #v1.0.0
        echo 0x0200 > bcdUSB      #USB 2.0


        #複数機能を持つUSBデバイスとしてWindowsに見せかけるにはこの設定が必要となる。
        echo 0xEF > bDeviceClass     #新規
        echo 0x02 > bDeviceSubClass  #新規
        echo 0x01 > bDeviceProtocol  #新規

        #USBシリアル等の設定をここで行う。serialnumberはあえて複雑な無意味な数字にしてあり、これをもとに差し込まれたPC側はUSBメモリの特定を行う。
        mkdir strings/0x409
        cd strings/0x409
        echo "SatoNobuhiro" > manufacturer
        echo "RaspberryEmulation" > product
        echo "310620932038831653350492731310" > serialnumber
        cd ../../

        #使用するデバイスの設定
        mkdir functions/rndis.usb0
        mkdir functions/mass_storage.usb0
        mkdir functions/hid.usb0

        #rndisがランダムなマックを使用しないように、固定マックを設定する。
        cd functions/rndis.usb0
        echo RNDIS > ./os_desc/interface.rndis/compatible_id
        echo 5162001 > ./os_desc/interface.rndis/sub_compatible_id
        cd ../../

        #hid.usb0について設定
        cd functions/hid.usb0
        echo 1 > protocol
        echo 1 > subclass
        echo 7 > report_length   #変更点(日本語キーボードをエミュレーションするため7である必要がある。)
        REPORT_DESCRIPTOR="\\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x99\\x81\\x00\\xc0"
        echo -ne $REPORT_DESCRIPTOR >  report_desc
        cd ../../

        #mass_storage.usb0について設定
        cd functions/mass_storage.usb0
        echo 0 > stall
        echo 1 > lun.0/removable
        echo 0 > lun.0/ro
        echo /dev/loop0 > lun.0/file
        cd ../../

        #OS Discripterの設定(Windowsで見えるようにする設定)
        cd os_desc
        echo 1 > use
        echo 0xcd > b_vendor_code
        echo MSFT100 > qw_sign
        cd ../

        #functionとconfigの紐づけ
        mkdir configs/c.1
        cd configs/c.1
        echo 250 > MaxPower
        mkdir strings/0x409
        echo "MDB Config1" > strings/0x409/configuration
        cd ../../
        ln -s functions/rndis.usb0 configs/c.1
        ln -s functions/mass_storage.usb0 configs/c.1
        ln -s functions/hid.usb0 configs/c.1

        ln -s configs/c.1 os_desc

        #デバイス有効化
        udevadm settle -t 5 || :
        ls /sys/class/udc > UDC
        ;;


    stop)
        echo "Stopping the USB gadget";

        echo "Disabling the USB gadget";
        cd /sys/kernel/config/usb_gadget/multiDeskBoard/;
        echo "" > /sys/kernel/config/usb_gadget/multiDeskBoard/UDC;

        echo "Cleaning up";
        rm configs/c.1/hid.usb0;
        rm configs/c.1/mass_storage.usb0;
        rm configs/c.1/rndis.usb0;
        rmdir functions/hid.usb0;
        rmdir functions/mass_storage.usb0;
        rmdir functions/rndis.usb0;
        rm os_desc/c.1

        echo "Cleaning up configuration";
        rmdir configs/c.1/strings/0x409;
        rmdir configs/c.1/strings/0x407;
        rmdir configs/c.1/;

        echo "Clearing strings";
        rmdir strings/0x409;
        rmdir strings/0x407;

        echo "Removing gadget directory";
        cd /sys/kernel/config/usb_gadget;
        rmdir multiDeskBoard;
        cd /;

        # modprobe -r libcomposite    # Remove composite module
        echo "OK";

        ;;
esac
