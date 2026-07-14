const statusEl  = document.getElementById('status')
const checkBtn  = document.getElementById('check-btn')
const installBtn = document.getElementById('install-btn')

async function init () {
  const info = await window.electronAPI.getAppInfo()
  document.getElementById('version').textContent  = info.version
  document.getElementById('feed-url').textContent = info.packaged
    ? info.feedUrl
    : '(app not packaged — autoUpdater disabled)'

  window.electronAPI.onUpdateStatus(({ type, message }) => {
    statusEl.className = type
    statusEl.textContent = message

    installBtn.disabled = (type !== 'downloaded')
    checkBtn.disabled   = (type === 'checking' || type === 'downloading')
  })
}

async function checkForUpdates () {
  const result = await window.electronAPI.checkForUpdates()
  if (result?.error) {
    statusEl.className = 'error'
    statusEl.textContent = result.error
  }
}

function installUpdate () {
  window.electronAPI.quitAndInstall()
}

init()
