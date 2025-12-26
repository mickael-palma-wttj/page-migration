# frozen_string_literal: true

module PageMigration
  # Shared rendering utilities for export generators
  module ContentRenderer
    def build_pages_index(org)
      pages = org['pages'] || []
      pages.each_with_object({}) { |p, h| h[p['id']] = p }
    end

    def build_tree_index(tree)
      (tree['page_tree'] || []).each_with_object({}) { |p, h| h[p['id']] = p }
    end

    def find_children(tree, parent_id)
      tree['page_tree'].select { |p| p['ancestry'] == parent_id.to_s }
    end

    def render_localized_value(key, localized)
      if key == 'body' && localized.to_s.length > 100
        "\n#{localized}\n\n"
      elsif localized.to_s.include?("\n")
        "- **#{key.capitalize}:**\n\n#{localized}\n\n"
      else
        "- **#{key.capitalize}:** #{localized}\n"
      end
    end

    def render_property(key, value, language)
      return nil if key == 'settings' || value.nil?

      if value.is_a?(Hash) && value.key?(language)
        localized = value[language]
        return nil if Utils.empty_value?(localized)

        render_localized_value(key, localized)
      elsif !value.is_a?(Hash)
        "- **#{key.capitalize}:** #{value}\n"
      end
    end
  end
end
