import requests

# Base URL for the Pokémon API
BASE_URL = "https://pokeapi.co/api/v2/"
# Limit to how many generations get created
GEN_LIMIT = 1

def get_types():
    print("-- Inserts for TABLE: TYPES")
    response = requests.get(f"{BASE_URL}type")
    data = response.json()
    
    # List to store SQL insert statements
    sql_inserts = []

    for type_info in data['results']:
        type_url = type_info['url']
        type_response = requests.get(type_url)
        type_data = type_response.json()

        type_id = type_data['id']
        type_name = type_data['name']

        # Create SQL insert statement
        sql_insert = f"INSERT INTO TYPE (type_id, type_name) VALUES ({type_id}, '{type_name}');"
        sql_inserts.append(sql_insert)

    # Print all SQL insert statements
    for insert in sql_inserts:
        print(insert)

def get_habitats():
    print("-- Inserts for TABLE: HABITATS")
    response = requests.get(f"{BASE_URL}pokemon-habitat")
    data = response.json()
    
    sql_inserts = []

    for habitat_info in data['results']:
        habitat_url = habitat_info['url']
        habitat_response = requests.get(habitat_url)
        habitat_data = habitat_response.json()

        habitat_id = habitat_data['id']
        habitat_name = habitat_data['name']

        sql_insert = f"INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES ({habitat_id}, '{habitat_name}', '');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_evol_methods():
    print("-- Inserts for TABLE: EVOL_METHODS")
    response = requests.get(f"{BASE_URL}evolution-trigger")
    data = response.json()
    
    sql_inserts = []

    for method_info in data['results']:
        method_url = method_info['url']
        method_response = requests.get(method_url)
        method_data = method_response.json()

        evol_method_id = method_data['id']
        evol_method_name = method_data['name']

        sql_insert = f"INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES ({evol_method_id}, '{evol_method_name}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_move_methods():
    print("-- Inserts for TABLE: MOVE_METHODS")
    response = requests.get(f"{BASE_URL}/move-learn-method/")
    if response.status_code != 200:
        print(f"Error fetching data: {response.status_code}")
        return

    move_methods_data = response.json()
    insert_statements = []

    for method in move_methods_data['results']:
        method_name = method['name']
        method_url = method['url']
        method_id = method_url.split('/')[-2]  # Extracting method id from the URL
        
        insert_statements.append(f"INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES ({method_id}, '{method_name}');")

    for statement in insert_statements:
        print(statement)

def get_generations():
    print("-- Inserts for TABLE: GENERATIONS")
    response = requests.get(f"{BASE_URL}generation")
    data = response.json()
    
    sql_inserts = []

    for generation_info in data['results']:
        generation_url = generation_info['url']
        generation_response = requests.get(generation_url)
        generation_data = generation_response.json()

        gen_id = generation_data['id']
        gen_name = generation_data['name']

        sql_insert = f"INSERT INTO GENERATION (gen_id, gen_name) VALUES ({gen_id}, '{gen_name}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_natures():
    print("-- Inserts for TABLE: NATURES")
    response = requests.get(f"{BASE_URL}nature")
    data = response.json()
    
    sql_inserts = []

    for nature_info in data['results']:
        nature_url = nature_info['url']
        nature_response = requests.get(nature_url)
        nature_data = nature_response.json()

        nat_id = nature_data['id']
        nat_name = nature_data['name']

        # Determine increased and decreased stats
        nat_increase = ''
        nat_decrease = ''
        if nature_data['increased_stat']:
            nat_increase = nature_data['increased_stat']['name'].replace("'", "''")
        if nature_data['decreased_stat']:
            nat_decrease = nature_data['decreased_stat']['name'].replace("'", "''")

        sql_insert = f"INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES ({nat_id}, '{nat_name}', '{nat_increase}', '{nat_decrease}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_status_effects():
    print("-- Inserts for TABLE: STATUS_EFFECTS")
    response = requests.get(f"{BASE_URL}move-ailment")
    data = response.json()
    
    sql_inserts = []

    for status_effect_info in data['results']:
        status_effect_url = status_effect_info['url']
        status_effect_response = requests.get(status_effect_url)
        status_effect_data = status_effect_response.json()

        stat_id = status_effect_data['id']
        stat_name = status_effect_data['name']
        stat_desc = status_effect_data['names'][0]['name'] if status_effect_data['names'] else ''

        sql_insert = f"INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES ({stat_id}, '{stat_name}', '{stat_desc}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_pokemon(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: POKEMON")
    sql_inserts = []
    
    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()

        pok_id = pokemon_data['id']
        pok_name = pokemon_data['name']
        pok_height = pokemon_data['height']
        pok_weight = pokemon_data['weight']
        pok_base_exp = pokemon_data['base_experience']
        
        # Extract effort values and structure them as a string
        ev_list = []
        stat_names = {
            'hp': 'HP',
            'attack': 'Attack',
            'defense': 'Defense',
            'special-attack': 'Special-Attack',
            'special-defense': 'Special-Defense',
            'speed': 'Speed'
        }

        for stat in pokemon_data['stats']:
            if stat['effort'] > 0:
                stat_name = stat_names.get(stat['stat']['name'], stat['stat']['name'].capitalize())
                ev_list.append(f"{stat_name}+{stat['effort']}")

        pok_ev = ','.join(ev_list) if ev_list else 'None'

        sql_insert = f"INSERT INTO POKEMON (pok_id, pok_name, pok_height, pok_weight, pok_base_exp, pok_ev) VALUES ({pok_id}, '{pok_name}', {pok_height}, {pok_weight}, {pok_base_exp}, '{pok_ev}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_items():
    print("-- Generating SQL file for TABLE: ITEMS")
    url = f"{BASE_URL}item"
    
    sql_inserts = []
    
    while url:
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
        except requests.RequestException as e:
            print(f"Error fetching data from {url}: {e}")
            break
        except ValueError:
            print(f"Invalid JSON response from {url}")
            break
        
        for item_info in data['results']:
            item_url = item_info['url']
            try:
                item_response = requests.get(item_url)
                item_response.raise_for_status()
                if not item_response.content.strip():  # Check if the response content is empty
                    print(f"Empty response from {item_url}")
                    continue
                item_data = item_response.json()
            except requests.RequestException as e:
                print(f"Error fetching item data from {item_url}: {e}")
                continue
            except ValueError:
                print(f"Invalid JSON response from {item_url}")
                continue

            item_id = item_data['id']
            item_name = item_data['name'].replace("'", "''")

            # Attempt to find the English description in flavor_text_entries
            item_desc = ''
            for entry in item_data['flavor_text_entries']:
                if entry['language']['name'] == 'en':
                    item_desc = entry['text'].replace("'", "''")
                    break

            # If no English flavor text entry is found, use the short_effect from effect_entries if available
            if not item_desc and item_data['effect_entries']:
                item_desc = item_data['effect_entries'][0]['short_effect'].replace("'", "''")

            item_category_id = int(item_data['category']['url'].split('/')[-2])

            sql_insert = f"INSERT INTO ITEM (item_id, item_name, item_desc, item_cat_id) VALUES ({item_id}, '{item_name}', '{item_desc}', {item_category_id});"
            sql_inserts.append(sql_insert)
        
        # Check for the next page
        url = data.get('next')
    
    # Write all insert statements to a SQL file in append mode with UTF-8 encoding
    file_name = "item-inserts.sql"
    with open(file_name, 'a', encoding='utf-8') as file:  # Use 'utf-8' encoding
        file.write("-- Inserts for TABLE: ITEMS\n")
        for insert in sql_inserts:
            file.write(insert + "\n")

    print(f"SQL inserts saved to {file_name}")

def get_item_categories():
    print("-- Inserts for TABLE: ITEM_CATEGORIES")
    url = f"{BASE_URL}item-category"
    
    sql_inserts = []
    
    while url:
        response = requests.get(url)
        data = response.json()
        
        for item_cat_info in data['results']:
            item_cat_url = item_cat_info['url']
            item_cat_response = requests.get(item_cat_url)
            item_cat_data = item_cat_response.json()
    
            item_cat_id = item_cat_data['id']
            item_cat_name = item_cat_data['name']
    
            sql_insert = f"INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES ({item_cat_id}, '{item_cat_name}');"
            sql_inserts.append(sql_insert)
        
        # Check for the next page
        url = data.get('next')
    
    for insert in sql_inserts:
        print(insert)

def get_type_efficacy():
    print("-- Inserts for TABLE: TYPE_EFFICACY")
    response = requests.get(f"{BASE_URL}type")
    data = response.json()
    
    sql_inserts = []

    for type_info in data['results']:
        type_url = type_info['url']
        type_response = requests.get(type_url)
        type_data = type_response.json()

        type_id = type_data['id']

        for damage_relation in type_data['damage_relations']['double_damage_to']:
            target_type_url = damage_relation['url']
            target_type_response = requests.get(target_type_url)
            target_type_data = target_type_response.json()
            target_type_id = target_type_data['id']
            sql_insert = f"INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES ({type_id}, {target_type_id}, 2.0);"
            sql_inserts.append(sql_insert)

        for damage_relation in type_data['damage_relations']['half_damage_to']:
            target_type_url = damage_relation['url']
            target_type_response = requests.get(target_type_url)
            target_type_data = target_type_response.json()
            target_type_id = target_type_data['id']
            sql_insert = f"INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES ({type_id}, {target_type_id}, 0.5);"
            sql_inserts.append(sql_insert)

        for damage_relation in type_data['damage_relations']['no_damage_to']:
            target_type_url = damage_relation['url']
            target_type_response = requests.get(target_type_url)
            target_type_data = target_type_response.json()
            target_type_id = target_type_data['id']
            sql_insert = f"INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES ({type_id}, {target_type_id}, 0.0);"
            sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_evolutions(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: EVOLUTIONS")
    sql_inserts = []

    # Fetch generation data to filter by generation
    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()
        evo_chain_url = pokemon_data['species']['url'].replace('pokemon-species', 'evolution-chain')
        
        evo_response = requests.get(evo_chain_url)
        if evo_response.status_code != 200:
            continue
        evolution_data = evo_response.json()
        chain = evolution_data['chain']

        def extract_evolution(chain, pre_evol_pok_id=None):
            pok_id = int(chain['species']['url'].split('/')[-2])
            if pre_evol_pok_id:
                evol_min_lvl = chain['evolution_details'][0].get('min_level') if chain['evolution_details'] else None
                evol_min_lvl = 'NULL' if evol_min_lvl is None else evol_min_lvl
                evol_method_id = chain['evolution_details'][0]['trigger']['url'].split('/')[-2] if chain['evolution_details'] else 'NULL'
                sql_insert = f"INSERT INTO EVOLUTION (pok_id, pre_evol_pok_id, evol_pok_id, evol_min_lvl, evol_method_id) VALUES ({pok_id}, {pre_evol_pok_id}, {pok_id}, {evol_min_lvl}, {evol_method_id});"
                sql_inserts.append(sql_insert)
            for evolves_to in chain['evolves_to']:
                extract_evolution(evolves_to, pok_id)

        extract_evolution(chain)

    for insert in sql_inserts:
        print(insert)

def get_abilities(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: ABILITIES")
    sql_inserts = []

    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    abilities_urls = [ability['url'] for ability in generation_data['abilities']]
    
    for ability_url in abilities_urls:
        response = requests.get(ability_url)
        if response.status_code != 200:
            continue
        ability_data = response.json()

        abi_id = ability_data['id']
        abi_name = ability_data['name']
        abi_desc = ability_data['effect_entries'][0]['short_effect'] if ability_data['effect_entries'] else ''

        sql_insert = f"INSERT INTO ABILITIES (abi_id, abi_name, abi_desc) VALUES ({abi_id}, '{abi_name}', '{abi_desc}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_base_stats(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: BASE_STATS")
    sql_inserts = []

    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()
        pok_id = pokemon_data['id']
        base_stats = pokemon_data['stats']

        b_hp = base_stats[0]['base_stat']
        b_atk = base_stats[1]['base_stat']
        b_def = base_stats[2]['base_stat']
        b_sp_atk = base_stats[3]['base_stat']
        b_sp_def = base_stats[4]['base_stat']
        b_speed = base_stats[5]['base_stat']

        sql_insert = f"INSERT INTO BASE_STATS (pok_id, b_hp, b_atk, b_def, b_sp_atk, b_sp_def, b_speed) VALUES ({pok_id}, {b_hp}, {b_atk}, {b_def}, {b_sp_atk}, {b_sp_def}, {b_speed});"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_individual_values(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: INDIVIDUAL_VALUES")
    sql_inserts = []

    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()
        pok_id = pokemon_data['id']
        iv_hp = iv_atk = iv_def = iv_sp_atk = iv_sp_def = iv_speed = 31  # Default maximum IVs

        sql_insert = f"INSERT INTO INDIVIDUAL_VALUES (pok_id, iv_hp, iv_atk, iv_def, iv_sp_atk, iv_sp_def, iv_speed) VALUES ({pok_id}, {iv_hp}, {iv_atk}, {iv_def}, {iv_sp_atk}, {iv_sp_def}, {iv_speed});"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_effort_values(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: EFFORT_VALUES")
    
    # Fetch generation data to filter by generation
    response = requests.get(f"{BASE_URL}generation/{limit}")
    if response.status_code != 200:
        print(f"Error fetching generation data: {response.status_code}")
        return

    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    sql_inserts = []

    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()
        pok_id = pokemon_data['id']
        
        # Default EVs set to 0
        ev_hp = ev_atk = ev_def = ev_sp_atk = ev_sp_def = ev_speed = 0
        
        sql_insert = f"""INSERT INTO EFFORT_VALUES (pok_id, ev_hp, ev_atk, ev_def, ev_sp_atk, ev_sp_def, ev_speed) VALUES ({pok_id}, {ev_hp}, {ev_atk}, {ev_def}, {ev_sp_atk}, {ev_sp_def}, {ev_speed});"""
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_moves(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: MOVES")
    sql_inserts = []

    # Fetch generation data to filter by generation
    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    move_urls = [move['url'] for move in generation_data['moves']]
    
    for move_url in move_urls:
        response = requests.get(move_url)
        if response.status_code != 200:
            continue
        move_data = response.json()

        move_id = move_data['id']
        move_name = move_data['name']
        move_pp = move_data['pp']
        move_power = move_data['power'] if move_data['power'] else 'NULL'
        move_accuracy = move_data['accuracy'] if move_data['accuracy'] else 'NULL'
        type_id = int(move_data['type']['url'].split('/')[-2])
        move_type = move_data['damage_class']['name'].replace("'", "''")

        sql_insert = f"INSERT INTO MOVE (move_id, type_id, move_name, move_pp, move_power, move_accuracy, move_type) VALUES ({move_id}, {type_id}, '{move_name}', {move_pp}, {move_power}, {move_accuracy}, '{move_type}');"
        sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_movesets(pokemon_name):
    print(f"-- Fetching movesets for {pokemon_name}")
    insert_statements = []

    try:
        # Fetch data from PokeAPI for the given pokemon
        response = requests.get(f"{BASE_URL}/pokemon/{pokemon_name.lower()}")
        response.raise_for_status()
        pokemon_data = response.json()
        pok_id = pokemon_data['id']
    except requests.RequestException as e:
        print(f"Error fetching data for {pokemon_name}: {e}")
        return insert_statements
    
    # Prepare the SQL insert statement
    for move in pokemon_data['moves']:
        move_name = move['move']['name']
        # print(move_name)
        move_id = move['move']['url'].split('/')[-2]  # Extracting move id from the URL

        for version_group in move['version_group_details']:
            method_name = version_group['move_learn_method']['name']
            method_id = version_group['move_learn_method']['url'].split('/')[-2]  # Extracting method id from the URL

            try:
                # Get the generation the move is learned from the URL
                gen_response = requests.get(f"{BASE_URL}/version-group/{version_group['version_group']['name']}/")
                gen_response.raise_for_status()
                gen_data = gen_response.json()
                gen_url = gen_data['generation']['url']  # Extracting gen id from the URL
                
                gen_response = requests.get(gen_url)
                gen_response.raise_for_status()
                gen_data = gen_response.json()
                gen_id = gen_data['id']
            except requests.RequestException as e:
                print(f"Error fetching generation data for version group {version_group['version_group']['name']}: {e}")
                continue

            level_learned = version_group['level_learned_at']

            # Create a unique tuple and add it to the list
            insert_statements.append(f"INSERT INTO MOVESET (pok_id, gen_id, move_id, move_method_id, level_learned) VALUES ({pok_id}, {gen_id}, {move_id}, {method_id}, {level_learned});")

            for insert_statement in insert_statements:
                print(insert_statement)

    return insert_statements

def get_gen_movesets(limit=GEN_LIMIT):
    print(f"-- Fetching movesets for all Pokémon from generation {limit}")
    all_inserts = []

    try:
        # Fetch data from PokeAPI for the specified generation
        response = requests.get(f"{BASE_URL}/generation/{limit}")
        response.raise_for_status()
        generation_data = response.json()
        pokemon_species = generation_data['pokemon_species']
    except requests.RequestException as e:
        print(f"Error fetching data for generation {limit}: {e}")
        return
    
    # Get the names of all Pokémon in the specified generation
    pokemon_names = [species['name'] for species in pokemon_species]

    for pokemon_name in pokemon_names:
        print(pokemon_name)
    
    # Use the get_pokemon_moveset function to get movesets for each Pokémon
    for pokemon_name in pokemon_names:
        print(pokemon_name)
        inserts = get_movesets(pokemon_name)
        all_inserts.extend(inserts)

    # Write all insert statements to a SQL file
    file_name = f"gen-{limit}-movesets.sql"
    with open(file_name, 'w') as file:
        file.write("-- Inserts for TABLE: MOVESET\n")
        for insert in all_inserts:
            file.write(insert + "\n")

    print(f"SQL inserts for generation {limit} saved to {file_name}")

def get_pok_abilities(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: POKEMON_POSSESSES_ABILITY")
    sql_inserts = []
    
    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()

        pok_id = pokemon_data['id']

        for ability_info in pokemon_data['abilities']:
            abi_id = int(ability_info['ability']['url'].split('/')[-2])
            is_hidden = ability_info['is_hidden']

            sql_insert = f"INSERT INTO POKEMON_POSSESSES_ABILITY (pok_id, abi_id, is_hidden) VALUES ({pok_id}, {abi_id}, {is_hidden});"
            sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

def get_pok_types(limit=GEN_LIMIT):
    print("-- Inserts for TABLE: POKEMON_BEARS_TYPE")
    sql_inserts = []
    
    response = requests.get(f"{BASE_URL}generation/{limit}")
    generation_data = response.json()
    species_urls = [species['url'] for species in generation_data['pokemon_species']]
    
    for species_url in species_urls:
        response = requests.get(species_url.replace('pokemon-species', 'pokemon'))
        if response.status_code != 200:
            continue
        pokemon_data = response.json()

        pok_id = pokemon_data['id']

        for type_info in pokemon_data['types']:
            type_id = int(type_info['type']['url'].split('/')[-2])

            sql_insert = f"INSERT INTO POKEMON_BEARS_TYPE (pok_id, type_id) VALUES ({pok_id}, {type_id});"
            sql_inserts.append(sql_insert)

    for insert in sql_inserts:
        print(insert)

# Functions to get data and generate SQL inserts for pokedex-inserts.sql
# get_types()
# get_habitats()
# get_evol_methods()
# get_move_methods()
# get_generations()
get_natures()
# get_status_effects()
# get_item_categories()
# get_type_efficacy()

# Gen-specific functions to get data and generate SQL inserts
# get_pokemon()
# get_evolutions()
# get_abilities()
# get_base_stats()
# get_individual_values()
# get_effort_values()
# get_moves()
# get_pok_abilities()
# get_pok_types()


# Functions to get data and generate SQL inserts in seperate files
# get_items()

# Moveset functions
# get_gen_movesets()
# get_movesets('squirtle')
