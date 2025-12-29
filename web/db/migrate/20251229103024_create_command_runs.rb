class CreateCommandRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :command_runs do |t|
      t.string :command, null: false
      t.string :org_ref
      t.json :options, default: {}
      t.string :status, default: "pending", null: false
      t.text :output
      t.text :error
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :command_runs, :status
    add_index :command_runs, :org_ref
    add_index :command_runs, :created_at
  end
end
