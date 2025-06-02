// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
// Temporarily comment out controllers to fix login issue
// import "./controllers"

// Minimal Stimulus setup for basic functionality
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

console.log("Application JS loaded successfully")
