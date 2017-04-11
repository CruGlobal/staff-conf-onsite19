class CreateMealExemptions < ActiveRecord::Migration
  def change
    create_table :meal_exemptions do |t|
      t.date :date
      t.references :attendee, references: :people, index: true
      t.string :meal_type

      t.timestamps

      t.index [:attendee_id, :date, :meal_type], unique: true
      t.foreign_key :people, column: :attendee_id
    end
  end
end
