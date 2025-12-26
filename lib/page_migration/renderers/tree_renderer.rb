# frozen_string_literal: true

module PageMigration
  module Renderers
    # Shared tree rendering utilities for hierarchical display
    module TreeRenderer
      CONNECTOR_LAST = '└── '
      CONNECTOR_MIDDLE = '├── '
      PREFIX_LAST = '    '
      PREFIX_MIDDLE = '│   '

      STATUS_PUBLISHED = '✅'
      STATUS_DRAFT = '❌'

      def tree_connector(is_last)
        is_last ? CONNECTOR_LAST : CONNECTOR_MIDDLE
      end

      def tree_prefix(current_prefix, is_last)
        current_prefix + (is_last ? PREFIX_LAST : PREFIX_MIDDLE)
      end

      def status_icon(status)
        status == 'published' ? STATUS_PUBLISHED : STATUS_DRAFT
      end
    end
  end
end
