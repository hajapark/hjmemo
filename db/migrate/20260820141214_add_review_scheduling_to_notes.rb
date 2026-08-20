class AddReviewSchedulingToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes,
      :next_review_at,
      :datetime,
      null: false,
      default: -> { "CURRENT_TIMESTAMP" }

    add_column :notes, :last_reviewed_at, :datetime

    add_column :notes,
      :review_interval_days,
      :integer,
      null: false,
      default: 0

    add_column :notes,
      :repetitions,
      :integer,
      null: false,
      default: 0

    add_column :notes,
      :ease_factor,
      :decimal,
      precision: 4,
      scale: 2,
      null: false,
      default: 2.5

    add_index :notes, :next_review_at

    add_check_constraint :notes,
      "review_interval_days >= 0",
      name: "notes_review_interval_days_non_negative"

    add_check_constraint :notes,
      "repetitions >= 0",
      name: "notes_repetitions_non_negative"

    add_check_constraint :notes,
      "ease_factor >= 1.3",
      name: "notes_ease_factor_minimum"
  end
end
