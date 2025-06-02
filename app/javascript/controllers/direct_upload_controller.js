import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="direct-upload"
export default class extends Controller {
  static targets = ["input", "videoInput", "progress", "preview", "dropzone", "foldersList"]
  static values = { maxFiles: Number, maxSize: Number }

  connect() {
    console.log("Enhanced direct upload controller connected")
    this.bindEvents()
    this.setupDragDrop()
    this.folders = []
    this.currentFolder = null
  }

  bindEvents() {
    if (this.hasInputTarget) {
      this.setupFileInputEvents(this.inputTarget, 'photo')
    }
    
    if (this.hasVideoInputTarget) {
      this.setupFileInputEvents(this.videoInputTarget, 'video')
    }
  }

  setupFileInputEvents(input, type) {
    input.addEventListener("direct-upload:initialize", event => {
      console.log(`${type} upload initialized`, event)
    })

    input.addEventListener("direct-upload:start", event => {
      console.log(`${type} upload started`, event)
      this.showProgress()
    })

    input.addEventListener("direct-upload:progress", event => {
      const { id, progress } = event.detail
      console.log(`${type} upload progress: ${progress}%`)
      this.updateProgress(progress)
    })

    input.addEventListener("direct-upload:error", event => {
      event.preventDefault()
      const { id, error } = event.detail
      console.error(`Error during ${type} upload: ${error}`)
      this.showError(`Erreur lors du téléchargement de ${type === 'photo' ? 'la photo' : 'la vidéo'} : ${error}`)
      this.hideProgress()
    })

    input.addEventListener("direct-upload:end", event => {
      console.log(`${type} upload ended`, event)
      this.hideProgress()
    })

    input.addEventListener("change", (event) => {
      this.handleFileSelection(event.target.files, type)
    })
  }

  setupDragDrop() {
    if (!this.hasDropzoneTarget) return

    const dropzone = this.dropzoneTarget

    dropzone.addEventListener("dragover", (e) => {
      e.preventDefault()
      dropzone.classList.add("border-primary", "bg-primary", "bg-opacity-10")
    })

    dropzone.addEventListener("dragleave", (e) => {
      e.preventDefault()
      dropzone.classList.remove("border-primary", "bg-primary", "bg-opacity-10")
    })

    dropzone.addEventListener("drop", (e) => {
      e.preventDefault()
      dropzone.classList.remove("border-primary", "bg-primary", "bg-opacity-10")
      
      const files = Array.from(e.dataTransfer.files)
      this.handleDroppedFiles(files)
    })
  }

  handleDroppedFiles(files) {
    const imageFiles = files.filter(file => file.type.startsWith('image/'))
    const videoFiles = files.filter(file => file.type.startsWith('video/'))
    
    if (imageFiles.length > 0) {
      this.handleFileSelection(imageFiles, 'photo')
    }
    
    if (videoFiles.length > 0) {
      this.handleFileSelection(videoFiles, 'video')
    }
  }

  handleFileSelection(files, type) {
    if (!files || files.length === 0) return

    const fileArray = Array.from(files)
    
    // Validate file count
    if (this.maxFilesValue && fileArray.length > this.maxFilesValue) {
      this.showError(`Vous ne pouvez télécharger que ${this.maxFilesValue} fichiers maximum`)
      return
    }

    // Validate file sizes
    const oversizedFiles = fileArray.filter(file => 
      this.maxSizeValue && file.size > this.maxSizeValue * 1024 * 1024
    )
    
    if (oversizedFiles.length > 0) {
      this.showError(`Certains fichiers dépassent la taille maximale de ${this.maxSizeValue}MB`)
      return
    }

    // Add files to current folder or main preview
    fileArray.forEach(file => {
      this.addFilePreview(file, type)
    })
  }

  addFilePreview(file, type) {
    if (!this.hasPreviewTarget) return

    const reader = new FileReader()
    reader.onload = (e) => {
      const preview = this.createFilePreview(file, e.target.result, type)
      
      if (this.currentFolder) {
        this.addFileToFolder(this.currentFolder, preview, file, type)
      } else {
        this.previewTarget.appendChild(preview)
      }
    }
    reader.readAsDataURL(file)
  }

  createFilePreview(file, src, type) {
    const div = document.createElement('div')
    div.className = 'relative group bg-base-100 rounded-lg overflow-hidden shadow-sm border border-base-300'
    div.setAttribute('data-file-type', type)
    div.setAttribute('data-file-name', file.name)

    const isVideo = type === 'video'
    const mediaElement = isVideo ? 'video' : 'img'
    const mediaAttributes = isVideo ? 'controls muted' : ''

    div.innerHTML = `
      <${mediaElement} 
        src="${src}" 
        class="w-full h-32 object-cover" 
        ${mediaAttributes}
        alt="${isVideo ? 'Aperçu vidéo' : 'Aperçu photo'}"
      >
      <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-200 flex items-center justify-center opacity-0 group-hover:opacity-100">
        <div class="text-center text-white">
          <div class="badge ${isVideo ? 'badge-secondary' : 'badge-accent'} mb-1">
            ${isVideo ? '🎥' : '📸'} ${file.name.split('.').pop().toUpperCase()}
          </div>
          <p class="text-xs">${(file.size / 1024).toFixed(0)} KB</p>
          <button type="button" class="btn btn-error btn-xs mt-1" data-action="click->direct-upload#removeFile">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1-1H8a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
      </div>
    `

    return div
  }

  removeFile(event) {
    event.preventDefault()
    const filePreview = event.target.closest('[data-file-type]')
    if (filePreview) {
      filePreview.remove()
    }
  }

  createFolder() {
    const folderName = prompt("Nom du dossier:")
    if (!folderName) return

    const folder = {
      id: Date.now(),
      name: folderName,
      files: []
    }

    this.folders.push(folder)
    this.renderFolders()
  }

  selectFolder(event) {
    const folderId = parseInt(event.currentTarget.dataset.folderId)
    this.currentFolder = this.folders.find(f => f.id === folderId)
    this.updateFolderSelection()
  }

  addFileToFolder(folder, preview, file, type) {
    folder.files.push({ preview, file, type })
    this.renderFolders()
  }

  renderFolders() {
    if (!this.hasFoldersListTarget) return

    this.foldersListTarget.innerHTML = ''
    
    this.folders.forEach(folder => {
      const folderElement = document.createElement('div')
      folderElement.className = `folder-item p-3 border border-base-300 rounded-lg cursor-pointer transition-all hover:bg-base-200 ${this.currentFolder?.id === folder.id ? 'bg-primary bg-opacity-20 border-primary' : ''}`
      folderElement.dataset.folderId = folder.id
      folderElement.dataset.action = "click->direct-upload#selectFolder"
      
      folderElement.innerHTML = `
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <svg class="w-5 h-5 mr-2 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"></path>
            </svg>
            <span class="font-medium">${folder.name}</span>
          </div>
          <span class="badge badge-neutral">${folder.files.length}</span>
        </div>
        <div class="mt-2 grid grid-cols-4 gap-1">
          ${folder.files.slice(0, 4).map(f => `
            <div class="w-8 h-8 bg-base-300 rounded overflow-hidden">
              ${f.type === 'video' ? 
                `<video src="${f.preview.querySelector('video').src}" class="w-full h-full object-cover"></video>` :
                `<img src="${f.preview.querySelector('img').src}" class="w-full h-full object-cover">`
              }
            </div>
          `).join('')}
          ${folder.files.length > 4 ? `<div class="w-8 h-8 bg-base-300 rounded flex items-center justify-center text-xs">+${folder.files.length - 4}</div>` : ''}
        </div>
      `
      
      this.foldersListTarget.appendChild(folderElement)
    })
  }

  updateFolderSelection() {
    this.renderFolders()
  }

  showProgress() {
    if (this.hasProgressTarget) {
      this.progressTarget.classList.remove("hidden")
    }
  }

  hideProgress() {
    if (this.hasProgressTarget) {
      this.progressTarget.classList.add("hidden")
    }
  }

  updateProgress(value) {
    if (this.hasProgressTarget) {
      this.progressTarget.value = value
    }
  }

  showError(message) {
    // Create a toast notification
    const toast = document.createElement('div')
    toast.className = 'toast toast-top toast-end'
    toast.innerHTML = `
      <div class="alert alert-error">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>${message}</span>
      </div>
    `
    
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.remove()
    }, 5000)
  }
} 