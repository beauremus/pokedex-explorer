class Evolution < ApplicationRecord
  belongs_to :predecessor, class_name: 'Pokemon', foreign_key: 'from_pokemon_id'
  belongs_to :successor, class_name: 'Pokemon', foreign_key: 'to_pokemon_id'
end
