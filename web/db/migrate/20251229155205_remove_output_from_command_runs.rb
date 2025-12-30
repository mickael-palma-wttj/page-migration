class RemoveOutputFromCommandRuns < ActiveRecord::Migration[8.1]
  def change
    remove_column :command_runs, :output, :text
  end
end
