require 'net/http'
require 'uri'
require 'json'
require 'set'

POKEAPI_BASE_URL = 'https://pokeapi.co/api/v2/'
GENERATION_1_LIMIT = 151

def fetch_api_data(url_string)
  uri = URI.parse(url_string)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  http.open_timeout = 5 # seconds
  http.read_timeout = 10 # seconds
  request = Net::HTTP::Get.new(uri.request_uri)
  request['User-Agent'] = 'PokedexExplorer-Script/1.0'

  begin
    response = http.request(request)

  unless response.is_a?(Net::HTTPSuccess)
      puts "HTTP Error fetching #{url_string}: #{response.code} #{response.message}"
      return nil
  end

  JSON.parse(response.body)

  rescue => e
    puts "Error fetching/parsing #{url_string}: #{e.message}"
    nil
  end
end

puts "Clearing existing Pokemon and Evolution data..."

# Wrap in transaction for atomicity
ActiveRecord::Base.transaction do
  Evolution.destroy_all
  Pokemon.destroy_all

  puts "Fetching and creating Gen 1 Pokémon..."
  # Create Pokemon records
  (1..GENERATION_1_LIMIT).each do |pokemon_id|
    pokemon_url = "#{POKEAPI_BASE_URL}pokemon/#{pokemon_id}"
    pokemon_data = fetch_api_data(pokemon_url)

    unless pokemon_data
      puts "Skipping Pokemon ID #{pokemon_id} due to fetch error."
      next
    end

    name = pokemon_data['name']
    puts "Processing #{name.capitalize}..."

    # Ensure names are unique
    pokemon = Pokemon.find_or_initialize_by(name: name)

    # Map data to ActiveRecord Pokemon model attributes
    pokemon.image_url = pokemon_data['sprites']['front_default']
    pokemon.type1 = pokemon_data['types'][0]['type']['name']
    pokemon.type2 = pokemon_data['types'].size > 1 ? pokemon_data['types'][1]['type']['name'] : nil

    unless pokemon.save
      puts "Failed to save #{name}: #{pokemon.errors.full_messages.join(', ')}"
    end
     sleep(0.1) # Be nice to the API
  end

  puts "\nFetching and creating Evolution links..."
  # Create Evolution records
  # A second pass ensures that all pokemon exist before creating evoltion entries
  (1..GENERATION_1_LIMIT).each do |pokemon_id|
     pokemon_url = "#{POKEAPI_BASE_URL}pokemon/#{pokemon_id}"
     pokemon_data = fetch_api_data(pokemon_url)
     next unless pokemon_data

     species_url = pokemon_data['species']['url']
     species_data = fetch_api_data(species_url)
     next unless species_data && species_data['evolves_from_species']

     current_pokemon_name = pokemon_data['name']
     evolves_from_name = species_data['evolves_from_species']['name']

     puts "Checking evolution: #{evolves_from_name.capitalize} -> #{current_pokemon_name.capitalize}"

     to_poke = Pokemon.find_by(name: current_pokemon_name)
     from_poke = Pokemon.find_by(name: evolves_from_name)

     if to_poke && from_poke
      puts "DEBUG: Creating Evolution with from=#{from_poke.class}##{from_poke.id} to=#{to_poke.class}##{to_poke.id}"
       # Use find_or_create_by! to avoid duplicates if script runs again
      # evo = Evolution.find_or_create_by!(from_pokemon_id: from_poke.id, to_pokemon_id: to_poke.id) do |e|
      evo = Evolution.create!(from_pokemon_id: from_poke.id, to_pokemon_id: to_poke.id) do |e|
         e.trigger_info = "Unknown"
       end
       puts "  Created evolution link: #{from_poke.name.capitalize} -> #{to_poke.name.capitalize}" if evo.persisted?
     else
       puts "  Skipping evolution link - missing Pokemon record for #{evolves_from_name} or #{current_pokemon_name}"
     end
     sleep(0.1) # Be nice to the API
  end

end

puts "\nSeeding finished!"

