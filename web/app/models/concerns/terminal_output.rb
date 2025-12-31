# frozen_string_literal: true

# Handles terminal output processing, specifically carriage return handling
# for progress bars and other terminal-style output.
module TerminalOutput
  extend ActiveSupport::Concern

  class_methods do
    # Process carriage returns to simulate terminal behavior.
    # When \r appears, it resets to the beginning of the line,
    # so only the last content before \n is shown.
    def process_carriage_returns(text)
      return "" if text.blank?

      text.split("\n", -1).map do |line|
        next line unless line.include?("\r")

        segments = line.split("\r")
        segments.reject(&:empty?).last || ""
      end.join("\n")
    end
  end
end
