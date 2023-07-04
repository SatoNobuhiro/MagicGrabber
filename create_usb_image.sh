#Copyright (c) 2023 Sato Nobuhiro
#All rights reserved.
#Redistribution of this software in any form without permission from the rights holder is not permitted.
#IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#USBメモリのイメージファイル(FAT32でフォーマット済みかつ、シェルスクリプト内蔵済み)をメモリ上に展開する。
sudo unzip usb_storage.zip -d /dev/shm/;
sleep 5;

#展開したイメージファイルをループバックデバイスと紐づけることで、ブロックデバイスとして取り扱えるようにする。
sudo losetup /dev/loop0 /dev/shm/usb_storage.img;
sleep 5;

#ループバックデバイスをマウントすることでディレクトリとしてあつかえるようにする。
if [ -e {/media/usb_storage} ]; then
    sudo mount /dev/loop0 /media/usb_storage;
else
    sudo mkdir -p /media/usb_storage
    sudo mount /dev/loop0 /media/usb_storage;
fi
sleep 3;

#ループバックデバイスを外部に公開するスクリプトを開始する。
sudo ./multi_device_emulation.sh start


