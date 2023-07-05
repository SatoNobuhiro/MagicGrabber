#Copyright (c) 2023 Sato Nobuhiro
#All rights reserved.
#Redistribution of this software in any form without permission from the rights holder is not permitted.
#IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sudo apt-get update && sudo apt-get install pip -y;
sudo pip install bottle


echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt;
echo "dwc2" | sudo tee -a /etc/modules;

sudo chmod 777 create_usb_image.sh
sudo chmod 777 multi_device_emulation.sh


USERNAME=$(whoami)
CURRENTDIR=$(pwd)

crontab -l > tmp
echo "@reboot sleep 10; sudo $CURRENTDIR/create_usb_image.sh" > tmp
echo "@reboot sleep 15; sudo python $CURRENTDIR/WebServer.py" >> tmp
crontab -u $USERNAME tmp
rm tmp