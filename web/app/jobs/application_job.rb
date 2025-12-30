# frozen_string_literal: true

require "net/http"

class ApplicationJob < ActiveJob::Base
  # Retry on database deadlock with exponential backoff
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  # Discard job if the underlying record was deleted
  discard_on ActiveJob::DeserializationError

  # Retry on transient network errors
  retry_on Net::OpenTimeout, wait: 5.seconds, attempts: 3
  retry_on Net::ReadTimeout, wait: 5.seconds, attempts: 3
end
