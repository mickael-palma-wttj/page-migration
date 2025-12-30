# frozen_string_literal: true

# Non-ActiveRecord model for organizations from external database
# Wraps OrganizationQuery service and provides domain logic
class Organization
  attr_reader :reference, :name, :has_export, :last_command_at

  def initialize(reference:, name: nil, has_export: false, last_command_at: nil)
    @reference = reference
    @name = name || reference
    @has_export = has_export
    @last_command_at = last_command_at
  end

  def has_export?
    @has_export
  end

  def to_param
    reference
  end

  class << self
    def search(query, limit: 50, include_export_status: false)
      return [] if query.blank?

      results = OrganizationQuery.search(query, limit: limit)
      results.map do |row|
        new(
          reference: row[:reference],
          name: row[:name],
          has_export: include_export_status ? ExportService.exists?(row[:reference]) : false
        )
      end
    rescue => e
      Rails.logger.error "[Organization] Search failed: #{e.message}"
      raise
    end

    def find_by_reference(reference)
      row = OrganizationQuery.find_by_reference(reference)
      return nil unless row

      new(reference: row[:reference], name: row[:name])
    end

    def recent_from_commands(limit: 10)
      CommandRun.where.not(org_ref: [nil, ""])
        .select(:org_ref)
        .group(:org_ref)
        .order(Arel.sql("MAX(created_at) DESC"))
        .limit(limit)
        .map { |cmd| build_from_command_run(cmd) }
    rescue => e
      Rails.logger.error "[Organization] Failed to fetch recent: #{e.message}"
      []
    end

    private

    def build_from_command_run(cmd)
      org = OrganizationQuery.find_by_reference(cmd.org_ref)
      new(
        reference: cmd.org_ref,
        name: org&.dig(:name),
        has_export: ExportService.exists?(cmd.org_ref),
        last_command_at: CommandRun.where(org_ref: cmd.org_ref).maximum(:created_at)
      )
    end
  end
end
