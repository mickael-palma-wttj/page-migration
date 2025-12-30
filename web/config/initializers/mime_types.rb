# frozen_string_literal: true

require "csv"

# Register CSV MIME type
# Rails doesn't include CSV by default, so we need to register it
Mime::Type.register "text/csv", :csv
