# frozen_string_literal: true

FactoryBot.define do
  factory :command_run do
    command { "extract" }
    status { "pending" }
    org_ref { "ABC123" }
    options { {} }

    trait :running do
      status { "running" }
      started_at { Time.current }
    end

    trait :completed do
      status { "completed" }
      started_at { 1.minute.ago }
      completed_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      started_at { 1.minute.ago }
      completed_at { Time.current }
      error { "Something went wrong" }
    end

    trait :stale do
      status { "running" }
      started_at { 10.minutes.ago }
      updated_at { 10.minutes.ago }
    end

    CommandRun::COMMANDS.each do |cmd|
      trait cmd.to_sym do
        command { cmd }
      end
    end
  end
end
