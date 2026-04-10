// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { initCapacitor } from "./capacitor_bridge"

// Init native bridge when running inside Capacitor shell
document.addEventListener("turbo:load", () => initCapacitor(), { once: true });
