#Copyright (c) 2023 Sato Nobuhiro
#All rights reserved.
#Redistribution of this software in any form without permission from the rights holder is not permitted.
#IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from bottle import route, run, template, request,  static_file, redirect
import os
import glob
from pathlib import Path
import ScriptParser
import subprocess
import time

#トップページにアクセスされた際の挙動
@route('/', method="GET")
def gettop():
    commandhistory = request.query.get("duckyscript")

    #トップページでduckyscriptが入力されていた場合、ScriptParserで対象コマンドを実行する。
    if commandhistory != None:
        ScriptParser.ScriptParser(commandhistory)
    files = GetFiles('/media/usb_storage/')
    
    imgtag = r'<img src="./images/latest.jpg?'+ str(time.time())  +'" id="remotescreen" class="screen">'

    return template('./index.html').format(imgtag, commandhistory, files)

#コマンドページにアクセスされた際の挙動
@route('/commands', method="GET")
def getcommands():
    return template('./commands.html')

#複数行コマンドを送られたときの挙動
@route('/commands', method="POST")
def getcommands():
    #ユーザーが入力してきたコマンドは複数行なので、分割してやる。
    multilinecommand = request.forms.get('text')
    singlelines = multilinecommand.splitlines()

    for singleline in singlelines:
        ScriptParser.ScriptParser(singleline)
    redirect('/')

#スクショの最新版ファイルを返す
@route('/images/latest.jpg')
def latest_jpg():
    latest_file = LoadLatestImg()
    latest_file_name = os.path.basename(latest_file)
    print(latest_file_name)
    return static_file(latest_file_name, root='/media/usb_storage/ScreenCapture')

#USBに保存されたファイルへの直接アクセス。
@route('/media/usb_storage/<filename>')
def usbdata(filename):
    return static_file(filename, root='/media/usb_storage')

#CSSを返す関数
@route('/css/<filename>')
def server_css(filename):
    return static_file(filename, root='./css')

#JavaScriptを返す関数
@route('/js/<filename>')
def serve_js(filename):
    return static_file(filename, root='./js')

#USBドライブ内からスクリーンショットを表示するための関数
def LoadLatestImg():

    usbdrive = r'/media/usb_storage/ScreenCapture/'
    targetfile = r'*.jpg'
    
    #対象のUSBドライブの中にある最新のjpgファイルのパスを取得してlatest_fileに取得
    paths = list(Path(usbdrive).glob(targetfile))
    paths.sort(reverse=True)
    return paths[1]
        

#指定されたパス直下のファイル一覧だけを取得する関数
def GetFiles(filepath):
    files = glob.glob(filepath+'*.*')
    links = ''
    for file in files:
        links=links + '<a href="' + file + '" target="_blank" rel="noopener noreferrer">' + os.path.basename(file) + '</a>'
    return links


#ファイルアップロード関数
@route('/upload', method='POST')
def do_upload():
    subprocess.run(['./multi_device_emulation.sh', 'stop'])
    uploads = request.files.getall('data')
    print('uploads',uploads)
    
    for upload in uploads:
        print(upload.filename)
        save_path = upload.filename
        upload.save('/media/usb_storage/'+save_path)

    time.sleep(5)
    subprocess.run(['./multi_device_emulation.sh', 'start'])
    return 'OK'


#直接呼び出された時の動作
if __name__ == '__main__':
    run(
        host='0.0.0.0',
        port=8080,
        reloader=True,
        debug=True)
