const { app, BrowserWindow, ipcMain, autoUpdater, dialog } = require('electron')
const path = require('path')

// Point this at your local Python http.server
const UPDATE_SERVER = 'http://localhost:8000'
const FEED_URL = `${UPDATE_SERVER}/updates/latest.json`

let mainWindow

function createWindow () {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  })

  mainWindow.loadFile(path.join(__dirname, 'index.html'))
}

function setupAutoUpdater () {
  // autoUpdater requires a packaged, code-signed app on macOS
  if (!app.isPackaged) {
    console.log('[AutoUpdater] Not packaged — skipping autoUpdater setup')
    return
  }

  console.log(`[AutoUpdater] Feed URL: ${FEED_URL}`)

  try {
    autoUpdater.setFeedURL({ url: FEED_URL })
  } catch (err) {
    console.error('[AutoUpdater] setFeedURL error:', err.message)
    sendStatus('error', `Init failed: ${err.message}`)
    return
  }

  autoUpdater.on('checking-for-update', () => {
    console.log('[AutoUpdater] Checking for update…')
    sendStatus('checking', 'Checking for updates…')
  })

  autoUpdater.on('update-available', () => {
    console.log('[AutoUpdater] Update available — downloading…')
    sendStatus('downloading', 'Update found! Downloading…')
  })

  autoUpdater.on('update-not-available', () => {
    console.log('[AutoUpdater] Up to date')
    sendStatus('up-to-date', 'Application is up to date.')
  })

  autoUpdater.on('update-downloaded', (event, releaseNotes, releaseName, releaseDate) => {
    console.log(`[AutoUpdater] Downloaded: ${releaseName} (${releaseDate})`)
    sendStatus('downloaded', `Update ${releaseName} downloaded — ready to install.`)

    dialog.showMessageBox(mainWindow, {
      type: 'info',
      title: 'Update Ready',
      message: `Version ${releaseName} is ready. Restart now to install?`,
      buttons: ['Restart Now', 'Later'],
    }).then(({ response }) => {
      if (response === 0) autoUpdater.quitAndInstall()
    })
  })

  autoUpdater.on('error', (err) => {
    console.error('[AutoUpdater] Error:', err.message)
    sendStatus('error', `Error: ${err.message}`)
  })
}

function sendStatus (type, message) {
  mainWindow?.webContents.send('update-status', { type, message })
}

ipcMain.handle('get-app-info', () => ({
  version: app.getVersion(),
  packaged: app.isPackaged,
  feedUrl: FEED_URL,
}))

ipcMain.handle('check-for-updates', () => {
  if (!app.isPackaged) {
    return { error: 'App must be packaged to use autoUpdater (run: npm run make)' }
  }
  autoUpdater.checkForUpdates()
  return { ok: true }
})

ipcMain.handle('quit-and-install', () => {
  autoUpdater.quitAndInstall()
})

app.whenReady().then(() => {
  createWindow()
  setupAutoUpdater()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})
