# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Export do
  let(:org_ref) { "Pg4eV6k" }
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => org_ref,
      "website" => "wttj_fr",
      "pages" => []
    }
  end
  let(:tree_data) do
    {
      "export_date" => "2024-01-01",
      "organization" => {"name" => "Test Company", "reference" => org_ref},
      "page_tree" => [],
      "statistics" => {"total_pages" => 0}
    }
  end
  let(:org_json) { {"organizations" => [org_data]}.to_json }
  let(:tree_json) { tree_data.to_json }
  let(:mock_conn) { double("connection") }
  let(:org_query) { instance_double(PageMigration::Queries::OrganizationQuery, call: org_json) }
  let(:tree_query) { instance_double(PageMigration::Queries::PageTreeQuery, call: tree_json) }
  let(:full_generator) { instance_double(PageMigration::Generators::FullExportGenerator, generate: "# Content") }
  let(:tree_generator) { instance_double(PageMigration::Generators::TreeExportGenerator, generate: nil) }

  before do
    allow(PageMigration::Database).to receive(:with_connection).and_yield(mock_conn)
    allow(PageMigration::Queries::OrganizationQuery).to receive(:new).and_return(org_query)
    allow(PageMigration::Queries::PageTreeQuery).to receive(:new).and_return(tree_query)
    allow(PageMigration::Generators::FullExportGenerator).to receive(:new).and_return(full_generator)
    allow(PageMigration::Generators::TreeExportGenerator).to receive(:new).and_return(tree_generator)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
  end

  describe "#call" do
    context "default export (single file per language)" do
      subject(:command) { described_class.new(org_ref) }

      it "queries organization and tree data" do
        expect(PageMigration::Queries::OrganizationQuery).to receive(:new).with(org_ref)
        expect(PageMigration::Queries::PageTreeQuery).to receive(:new).with(org_ref)
        expect { command.call }.to output.to_stdout
      end

      it "generates exports for default languages (fr, en)" do
        expect(PageMigration::Generators::FullExportGenerator).to receive(:new)
          .with(org_data, tree_data, hash_including(language: "fr"))
          .and_return(full_generator)
        expect(PageMigration::Generators::FullExportGenerator).to receive(:new)
          .with(org_data, tree_data, hash_including(language: "en"))
          .and_return(full_generator)
        expect { command.call }.to output.to_stdout
      end

      it "writes output files" do
        expect(File).to receive(:write).with(/Pg4eV6k_test_company_fr\.md$/, "# Content")
        expect(File).to receive(:write).with(/Pg4eV6k_test_company_en\.md$/, "# Content")
        expect { command.call }.to output.to_stdout
      end
    end

    context "with custom languages" do
      subject(:command) { described_class.new(org_ref, languages: %w[fr cs de]) }

      it "exports only specified languages" do
        expect(PageMigration::Generators::FullExportGenerator).to receive(:new)
          .exactly(3).times.and_return(full_generator)
        expect { command.call }.to output.to_stdout
      end
    end

    context "with custom_only option" do
      subject(:command) { described_class.new(org_ref, custom_only: true) }

      it "passes custom_only to generator" do
        expect(PageMigration::Generators::FullExportGenerator).to receive(:new)
          .with(anything, anything, hash_including(custom_only: true))
          .twice.and_return(full_generator)
        expect { command.call }.to output.to_stdout
      end

      it "adds _custom suffix to filenames" do
        expect(File).to receive(:write).with(/_custom\.md$/, anything).twice
        expect { command.call }.to output.to_stdout
      end
    end

    context "with tree option" do
      subject(:command) { described_class.new(org_ref, tree: true) }

      it "uses TreeExportGenerator" do
        expect(PageMigration::Generators::TreeExportGenerator).to receive(:new)
          .twice.and_return(tree_generator)
        expect { command.call }.to output.to_stdout
      end
    end

    context "with custom output_dir" do
      subject(:command) { described_class.new(org_ref, output_dir: "custom/export") }

      it "creates custom output directory" do
        expect(FileUtils).to receive(:mkdir_p).with("custom/export")
        expect { command.call }.to output.to_stdout
      end
    end
  end

  describe "LANGUAGES" do
    it "defaults to fr and en" do
      expect(described_class::LANGUAGES).to eq(%w[fr en])
    end
  end
end
