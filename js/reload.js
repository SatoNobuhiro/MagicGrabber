document.addEventListener('DOMContentLoaded', function () {
    const RELOAD_SPAN = 1000;
    function reload() {
        document.getElementById('remotescreen').src = './images/latest.jpg' + '?' + Date.now();
    }
    setInterval(reload, RELOAD_SPAN);
});

