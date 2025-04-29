class CreatePokemon < ActiveRecord::Migration[7.1]
  def change
    create_table :pokemon do |t|
      t.string :name
      t.string :image_url
      t.string :type1
      t.string :type2

      t.timestamps
    end
  end
end
