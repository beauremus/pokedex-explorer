# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data (optional, good during development)
if true
  puts "Destroying existing records..."
  Evolution.destroy_all
  Pokemon.destroy_all
end

puts "Creating Pokemon..."
eevee = Pokemon.create!(name: 'Eevee', type1: 'Normal', image_url: 'url/to/eevee.png')
vaporeon = Pokemon.create!(name: 'Vaporeon', type1: 'Water', image_url: 'url/to/vaporeon.png')
jolteon = Pokemon.create!(name: 'Jolteon', type1: 'Electric', image_url: 'url/to/jolteon.png')
flareon = Pokemon.create!(name: 'Flareon', type1: 'Fire', image_url: 'url/to/flareon.png')
# ... add other Gen 1 Pokemon as needed ...

puts "Creating Evolutions..."
Evolution.create!(from_pokemon: eevee, to_pokemon: vaporeon, trigger_info: 'Use Water Stone')
Evolution.create!(from_pokemon: eevee, to_pokemon: jolteon, trigger_info: 'Use Thunder Stone')
Evolution.create!(from_pokemon: eevee, to_pokemon: flareon, trigger_info: 'Use Fire Stone')
# ... add other evolution links ...

puts "Seeding finished!"
puts "Created #{Pokemon.count} Pokemon"
puts "Created #{Evolution.count} Evolutions":22

