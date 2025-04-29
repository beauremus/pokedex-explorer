class CreateEvolution < ActiveRecord::Migration[7.1]
  def change
    create_table :evolutions do |t|
      t.references :from_pokemon, null: false, foreign_key: { to_table: :pokemon }
      t.references :to_pokemon, null: false, foreign_key: { to_table: :pokemon }
      t.string :trigger_info

      t.timestamps
    end
  end
end
