// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { createConsumer } from "@rails/actioncable"

// Create ActionCable consumer early so Turbo Streams can connect immediately
window.Turbo.connectStreamSource = window.Turbo.connectStreamSource || (() => {})
const consumer = createConsumer()
window.cable = consumer
