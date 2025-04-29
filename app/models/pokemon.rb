class Pokemon < ApplicationRecord
  # Direct links to Evolution records
  has_many :evolutions_to, class_name: 'Evolution', foreign_key: 'from_pokemon_id', dependent: :destroy
  has_one :evolution_from, class_name: 'Evolution', foreign_key: 'to_pokemon_id', dependent: :destroy

  # The Pokemon this one evolves *into* (can be multiple, e.g., Eevee)
  has_many :evolves_into_pokemon, through: :evolutions_to, source: :successor # Using successor from Evolution model

  # The single Pokemon this one evolves *from* (should be zero or one)
  # Using has_one reflects the 0-or-1 relationship better
  has_one :evolves_from_pokemon, through: :evolution_from, source: :predecessor # Using predecessor from Evolution model

  validates :name, presence: true, uniqueness: true
  validates :type1, presence: true
end
