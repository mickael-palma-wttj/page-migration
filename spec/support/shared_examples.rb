# frozen_string_literal: true

# Shared examples for command classes
RSpec.shared_examples "a command" do
  it { is_expected.to respond_to(:call) }
end

# Shared examples for generator classes
RSpec.shared_examples "a generator" do
  it { is_expected.to respond_to(:generate) }
end

# Shared examples for query classes
RSpec.shared_examples "a query" do
  it { is_expected.to respond_to(:call) }
end
