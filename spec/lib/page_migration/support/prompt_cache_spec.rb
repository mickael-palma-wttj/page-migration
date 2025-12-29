# frozen_string_literal: true

require "fileutils"

RSpec.describe PageMigration::Support::PromptCache do
  let(:output_root) { "tmp/test_cache" }
  let(:cache) { described_class.new(output_root) }

  before do
    FileUtils.rm_rf(output_root)
    FileUtils.mkdir_p(output_root)
  end

  after do
    FileUtils.rm_rf(output_root)
  end

  describe "#initialize" do
    it "sets output root" do
      expect(cache.instance_variable_get(:@output_root)).to eq(output_root)
    end

    it "enables cache by default" do
      expect(cache.enabled?).to be true
    end

    it "can be disabled" do
      disabled_cache = described_class.new(output_root, enabled: false)
      expect(disabled_cache.enabled?).to be false
    end

    it "initializes stats to zero" do
      expect(cache.hits).to eq(0)
      expect(cache.misses).to eq(0)
    end
  end

  describe "#fingerprint" do
    it "generates consistent fingerprint for same inputs" do
      fp1 = cache.fingerprint("prompt content", "input summary")
      fp2 = cache.fingerprint("prompt content", "input summary")
      expect(fp1).to eq(fp2)
    end

    it "generates different fingerprints for different prompts" do
      fp1 = cache.fingerprint("prompt A", "input")
      fp2 = cache.fingerprint("prompt B", "input")
      expect(fp1).not_to eq(fp2)
    end

    it "generates different fingerprints for different inputs" do
      fp1 = cache.fingerprint("prompt", "input A")
      fp2 = cache.fingerprint("prompt", "input B")
      expect(fp1).not_to eq(fp2)
    end

    it "returns a SHA256 hash" do
      fp = cache.fingerprint("prompt", "input")
      expect(fp).to match(/^[a-f0-9]{64}$/)
    end
  end

  describe "#cached?" do
    it "returns false when not cached" do
      fp = cache.fingerprint("prompt", "input")
      expect(cache.cached?(fp)).to be false
    end

    it "returns true when cached" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      expect(cache.cached?(fp)).to be true
    end

    it "returns false when disabled" do
      disabled_cache = described_class.new(output_root, enabled: false)
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      expect(disabled_cache.cached?(fp)).to be false
    end
  end

  describe "#get" do
    it "returns nil when not cached" do
      fp = cache.fingerprint("prompt", "input")
      expect(cache.get(fp)).to be_nil
    end

    it "returns cached content" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "cached result")
      expect(cache.get(fp)).to eq("cached result")
    end

    it "increments hits counter" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      cache.get(fp)
      expect(cache.hits).to eq(1)
    end

    it "returns nil when disabled" do
      disabled_cache = described_class.new(output_root, enabled: false)
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      expect(disabled_cache.get(fp)).to be_nil
    end
  end

  describe "#set" do
    it "stores content in cache" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result content")

      # Verify file exists
      cache_path = File.join(output_root, ".cache", "#{fp[0..7]}.json")
      expect(File.exist?(cache_path)).to be true
    end

    it "increments misses counter" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      expect(cache.misses).to eq(1)
    end

    it "stores metadata" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result", {prompt: "test_prompt"})

      cache_path = File.join(output_root, ".cache", "#{fp[0..7]}.json")
      data = JSON.parse(File.read(cache_path))
      expect(data["prompt"]).to eq("test_prompt")
    end

    it "does nothing when disabled" do
      disabled_cache = described_class.new(output_root, enabled: false)
      fp = disabled_cache.fingerprint("prompt", "input")
      disabled_cache.set(fp, "result")

      cache_path = File.join(output_root, ".cache", "#{fp[0..7]}.json")
      expect(File.exist?(cache_path)).to be false
    end
  end

  describe "#fetch" do
    it "returns cached value without calling block" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "cached")

      block_called = false
      result = cache.fetch("prompt", "input") do
        block_called = true
        "new result"
      end

      expect(result).to eq("cached")
      expect(block_called).to be false
    end

    it "calls block and caches result when not cached" do
      result = cache.fetch("prompt", "input") { "computed result" }
      expect(result).to eq("computed result")

      # Verify it was cached
      fp = cache.fingerprint("prompt", "input")
      expect(cache.get(fp)).to eq("computed result")
    end

    it "does not cache nil results" do
      result = cache.fetch("prompt", "input") { nil }
      expect(result).to be_nil

      fp = cache.fingerprint("prompt", "input")
      expect(cache.cached?(fp)).to be false
    end
  end

  describe "#stats" do
    it "returns hits and misses" do
      fp1 = cache.fingerprint("prompt1", "input")
      cache.set(fp1, "result1")
      cache.get(fp1)
      cache.get(fp1)

      fp2 = cache.fingerprint("prompt2", "input")
      cache.set(fp2, "result2")

      stats = cache.stats
      expect(stats[:hits]).to eq(2)
      expect(stats[:misses]).to eq(2)
    end
  end

  describe "#hit_rate" do
    it "returns 0 when no operations" do
      expect(cache.hit_rate).to eq(0.0)
    end

    it "calculates correct hit rate" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")  # 1 miss
      cache.get(fp)             # 1 hit
      cache.get(fp)             # 2 hits

      # 2 hits out of 3 total = 66.7%
      expect(cache.hit_rate).to eq(66.7)
    end
  end

  describe "#clear!" do
    it "removes cache directory" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")

      cache.clear!

      cache_dir = File.join(output_root, ".cache")
      expect(Dir.exist?(cache_dir)).to be false
    end

    it "resets stats" do
      fp = cache.fingerprint("prompt", "input")
      cache.set(fp, "result")
      cache.get(fp)

      cache.clear!

      expect(cache.hits).to eq(0)
      expect(cache.misses).to eq(0)
    end
  end
end
