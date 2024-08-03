import pandas as pd
import requests

# Corrected file path with raw string literal
file_path = r'C:\Portal\University of Washington Bothell\2023 - 2024\Summer 2024\Datasets\Pokedex Tables\TEAM.csv'

# Load the CSV file
team_df = pd.read_csv(file_path)

# Function to fetch move ID from PokeAPI based on move name
def fetch_move_id(move_name):
    url = f"https://pokeapi.co/api/v2/move/{move_name}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json().get('id')
    else:
        return None

# Function to fetch Pokémon ID from PokeAPI based on Pokémon name
def fetch_pokemon_id(pokemon_name):
    url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_name.lower()}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json().get('id')
    else:
        return None

# Update trainer_id with sequential IDs
def assign_trainer_ids(df):
    current_trainer_id = 0
    trainer_ids = []

    # Initialize previous name as None for the first comparison
    previous_name = None

    for trainer_name in df['trainer_id']:
        # Check if the cell is blank or NaN
        if pd.isna(trainer_name) or trainer_name.strip() == "":
            trainer_ids.append(None)  # Assign None for blank cells
        else:
            # Increment ID if the current name is different from the previous name
            if previous_name is None or trainer_name != previous_name:
                current_trainer_id += 1
                print(f"{trainer_name} | ID: {current_trainer_id}")

            # Assign current ID and update previous_name
            trainer_ids.append(current_trainer_id)
            previous_name = trainer_name

    return trainer_ids

# List of unique move names in the DataFrame
move_columns = ['move1_id', 'move2_id', 'move3_id', 'move4_id']
unique_moves = pd.concat([team_df[col].dropna() for col in move_columns]).unique()

# Dictionary to store move name to move ID mapping
move_name_to_id = {}

# Fetch move IDs for each unique move name
for move in unique_moves:
    move_id = fetch_move_id(move)
    if move_id is not None:
        move_name_to_id[move] = move_id

# Replace move names with move IDs in the DataFrame
for col in move_columns:
    team_df[col] = team_df[col].map(move_name_to_id)

# Fetch Pokémon IDs for each unique Pokémon name
unique_pokemons = team_df['pok_id'].dropna().unique()
pokemon_name_to_id = {pokemon: fetch_pokemon_id(pokemon) for pokemon in unique_pokemons if fetch_pokemon_id(pokemon) is not None}

# Replace Pokémon names with Pokémon IDs in the DataFrame
team_df['pok_id'] = team_df['pok_id'].map(pokemon_name_to_id)

# Update trainer_id column
team_df['trainer_id'] = assign_trainer_ids(team_df)

# Save the updated DataFrame back to a CSV file
updated_file_path = r'C:\Portal\University of Washington Bothell\2023 - 2024\Summer 2024\Datasets\TEAM_updated.csv'
team_df.to_csv(updated_file_path, index=False)
