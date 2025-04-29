class PokemonController < ApplicationController
  def index
    @pokemon = Pokemon.order("RANDOM()").first
  end

  def show
    # 1. Find the Pokemon being viewed using the ID from the URL parameters
    puts params[:id]
    @pokemon = Pokemon.find(params[:id])
    puts @pokemon
    puts @pokemon.id
    puts @pokemon.name
    puts @pokemon.image_url

    # 2. Find Pokemon related by type using our private helper method
    @related_by_type = find_related_by_type(@pokemon)

    # 3. Find the direct evolutions (needed separately for the view)
    #    These use the associations defined in the Pokemon model
    @evolution_from = @pokemon.evolves_from_pokemon
    @evolutions_to = @pokemon.evolves_into_pokemon
    puts @evolution_from
    puts @evolution_to

    # Instance variables (@pokemon, @related_by_type, @evolution_from, @evolutions_to)
    # are now available to the show.html.erb view.
  end

  private #--------------------------------------------------------------------

  # Helper method to find related Pokemon based on shared types.
  # It excludes the focused Pokemon itself and its direct evolutions.
  def find_related_by_type(pokemon, limit = 6)
    # 1. Find the direct evolutions to get their IDs for exclusion.
    #    We use .to_a here to load them immediately for the .map(&:id) call.
    evolutions_to_list = pokemon.evolutions_to.map(&:id)
    evolution_from = pokemon.evolution_from

    # 2. Create a list of all IDs to exclude from the type search:
    #    - The focused pokemon itself
    #    - The pokemon it evolves from
    #    - All pokemon it evolves into
    # .compact excludes any nils
    exclude_ids = ([pokemon.id, evolution_from&.id]).compact + evolutions_to_list

    # 3. Start building the ActiveRecord query for Pokemon...
    #    ...excluding the IDs we just collected.
    #    (Assumes your Pokemon table name is 'pokemon' singular due to inflection rule)
    base_query = Pokemon.where.not(id: exclude_ids)

    # 4. Build the database condition to find matches for the first type.
    #    Finds Pokemon where *either* their type1 or type2 matches the focused Pokemon's type1.
    type1_match_conditions = base_query.where(type1: pokemon.type1).or(base_query.where(type2: pokemon.type1))

    # 5. Build conditions for the second type, *only if* the focused Pokemon has one.
    if pokemon.type2.present?
      type2_match_conditions = base_query.where(type1: pokemon.type2).or(base_query.where(type2: pokemon.type2))
      # Combine the conditions using OR: Match type 1 OR match type 2
      final_query = type1_match_conditions.or(type2_match_conditions)
    else
      # If the focused Pokemon only has one type, just use the type1 conditions
      final_query = type1_match_conditions
    end

    # 6. Ensure results are unique (distinct), apply the limit, and execute query.
    #    Optional: Add .order("RANDOM()") before .limit for variety on refresh (SQLite only).
    final_query.distinct.limit(limit)
  end
end
