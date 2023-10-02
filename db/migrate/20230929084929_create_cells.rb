class CreateCells < ActiveRecord::Migration[7.0]
  def change
    create_table :cells do |t|
      t.integer :row
      t.integer :column
      t.boolean :alive

      t.timestamps
    end
  end
end
