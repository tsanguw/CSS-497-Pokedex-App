-- Drop tables if they exist
DROP TABLE IF EXISTS TEAM;
DROP TABLE IF EXISTS TRAINER;
DROP TABLE IF EXISTS MOVE_HAS_STATUS_EFFECT;
DROP TABLE IF EXISTS POKEMON_EXHIBIT_A_NATURE;
DROP TABLE IF EXISTS POKEMON_BEARS_TYPE;
DROP TABLE IF EXISTS POKEMON_INHABITS_HABITAT;
DROP TABLE IF EXISTS POKEMON_POSSESSES_ABILITY;
DROP TABLE IF EXISTS TYPE_EFFICACY;
DROP TABLE IF EXISTS MOVESET;
DROP TABLE IF EXISTS EVOLUTION;
DROP TABLE IF EXISTS ITEM_HAS_CATEGORY;
DROP TABLE IF EXISTS ITEM;
DROP TABLE IF EXISTS ITEM_CATEGORY;
DROP TABLE IF EXISTS MOVE;
DROP TABLE IF EXISTS STATUS_EFFECT;
DROP TABLE IF EXISTS NATURE;
DROP TABLE IF EXISTS TYPE;
DROP TABLE IF EXISTS GENERATION;
DROP TABLE IF EXISTS MOVE_METHOD;
DROP TABLE IF EXISTS EVOLUTION_METHOD;
DROP TABLE IF EXISTS HABITAT;
DROP TABLE IF EXISTS ABILITIES;
DROP TABLE IF EXISTS INDIVIDUAL_VALUES;
DROP TABLE IF EXISTS EFFORT_VALUES;
DROP TABLE IF EXISTS BASE_STATS;
DROP TABLE IF EXISTS POKEMON;

-- Create POKEMON table
CREATE TABLE POKEMON (
    pok_id INT PRIMARY KEY,
    pok_name VARCHAR(50) NOT NULL,
    pok_height FLOAT CHECK (pok_height >= 0),
    pok_weight FLOAT CHECK (pok_weight >= 0),
    pok_base_exp INT CHECK (pok_base_exp >= 0),
    pok_ev VARCHAR(50)
);

-- Create ABILITIES table
CREATE TABLE ABILITIES (
    abi_id INT PRIMARY KEY,
    abi_name VARCHAR(50) NOT NULL UNIQUE,
    abi_desc TEXT
);

-- Create HABITAT table
CREATE TABLE HABITAT (
    hab_id INT PRIMARY KEY,
    hab_name VARCHAR(50) NOT NULL UNIQUE,
    hab_desc TEXT
);

-- Create MOVE METHOD table
CREATE TABLE MOVE_METHOD (
    move_method_id INT PRIMARY KEY,
    move_method_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create EVOLUTION METHOD table
CREATE TABLE EVOLUTION_METHOD (
    evol_method_id INT PRIMARY KEY,
    evol_method_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create GENERATION table
CREATE TABLE GENERATION (
    gen_id INT PRIMARY KEY,
    gen_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create TYPE table
CREATE TABLE TYPE (
    type_id INT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create NATURE table
CREATE TABLE NATURE (
    nat_id INT PRIMARY KEY,
    nat_name VARCHAR(50) NOT NULL UNIQUE,
    nat_increase VARCHAR(50),
    nat_decrease VARCHAR(50)
);

-- Create STATUS EFFECT table
CREATE TABLE STATUS_EFFECT (
    stat_id INT PRIMARY KEY,
    stat_name VARCHAR(50) NOT NULL UNIQUE,
    stat_desc TEXT
);

-- Create EVOLUTION table
CREATE TABLE EVOLUTION (
    pok_id INT,
    pre_evol_pok_id INT NULL, 
    evol_pok_id INT NULL,     
    evol_min_lvl INT NULL CHECK (evol_min_lvl >= 0),  
    evol_method_id INT,
    PRIMARY KEY (pok_id, pre_evol_pok_id, evol_pok_id, evol_method_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (pre_evol_pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (evol_pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (evol_method_id) REFERENCES EVOLUTION_METHOD(evol_method_id)
);

-- Create MOVE table
CREATE TABLE MOVE (
    move_id INT PRIMARY KEY,
    type_id INT,
    move_name VARCHAR(50) NOT NULL UNIQUE,
    move_pp INT CHECK (move_pp >= 0),
    move_power INT CHECK (move_power >= 0),
    move_accuracy FLOAT CHECK (move_accuracy >= 0 AND move_accuracy <= 100),
    move_type VARCHAR(50),
    move_effect VARCHAR(50),
    FOREIGN KEY (type_id) REFERENCES TYPE(type_id)
);

-- Create MOVESET table
CREATE TABLE MOVESET (
    pok_id INT,
    gen_id INT,
    move_id INT,
    method_id INT,
    level_learned INT CHECK (level_learned >= 0),
    PRIMARY KEY (pok_id, gen_id, move_id, method_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (gen_id) REFERENCES GENERATION(gen_id),
    FOREIGN KEY (move_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (method_id) REFERENCES MOVE_METHOD(move_method_id)
);

-- Create TYPE EFFICACY table
CREATE TABLE TYPE_EFFICACY (
    type_id INT,
    target_type_id INT,
    dmg_factor FLOAT CHECK (dmg_factor >= 0),
    PRIMARY KEY (type_id, target_type_id),
    FOREIGN KEY (type_id) REFERENCES TYPE(type_id),
    FOREIGN KEY (target_type_id) REFERENCES TYPE(type_id)
);

-- Create POKEMON POSSESSES ABILITY table
CREATE TABLE POKEMON_POSSESSES_ABILITY (
    pok_id INT,
    abi_id INT,
    is_hidden BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (pok_id, abi_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (abi_id) REFERENCES ABILITIES(abi_id)
);

-- Create POKEMON BEARS TYPE table
CREATE TABLE POKEMON_BEARS_TYPE (
    pok_id INT,
    type_id INT,
    PRIMARY KEY (pok_id, type_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (type_id) REFERENCES TYPE(type_id)
);

-- Create POKEMON EXHIBIT A NATURE table
CREATE TABLE POKEMON_EXHIBIT_A_NATURE (
    pok_id INT,
    nat_id INT,
    PRIMARY KEY (pok_id, nat_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (nat_id) REFERENCES NATURE(nat_id)
);

-- Create TRAINER table
CREATE TABLE TRAINER (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(50) NOT NULL,
    trainer_gym_name VARCHAR(50),
    trainer_game VARCHAR(50),
    trainer_gen INT,
    FOREIGN KEY (trainer_gen) REFERENCES GENERATION(gen_id)
);

-- Create TEAM table
CREATE TABLE TEAM (
    trainer_id INT,
    pok_id INT,
    pok_lvl INT CHECK (pok_lvl >= 1),
    position INT CHECK (position >= 1 AND position <= 6),
    move1_id INT NULL,
    move2_id INT NULL,
    move3_id INT NULL,
    move4_id INT NULL,
    PRIMARY KEY (trainer_id, pok_id, position),
    FOREIGN KEY (trainer_id) REFERENCES TRAINER(trainer_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (move1_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (move2_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (move3_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (move4_id) REFERENCES MOVE(move_id)
);

-- Create ITEM CATEGORY table
CREATE TABLE ITEM_CATEGORY (
    item_cat_id INT PRIMARY KEY,
    item_cat_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create ITEM table
CREATE TABLE ITEM (
    item_id INT,
    item_name VARCHAR(50) NOT NULL UNIQUE,
    item_desc TEXT,
    item_cat_id INT,
    PRIMARY KEY (item_id, item_cat_id),
    FOREIGN KEY (item_cat_id) REFERENCES ITEM_CATEGORY(item_cat_id)
);

-- Create BASE STATS table
CREATE TABLE BASE_STATS (
    b_hp INT CHECK (b_hp >= 0),
    b_atk INT CHECK (b_atk >= 0),
    b_def INT CHECK (b_def >= 0),
    b_sp_atk INT CHECK (b_sp_atk >= 0),
    b_sp_def INT CHECK (b_sp_def >= 0),
    b_speed INT CHECK (b_speed >= 0),
    pok_id INT,
    PRIMARY KEY (pok_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id)
);

-- Create INDIVIDUAL VALUES table
CREATE TABLE INDIVIDUAL_VALUES (
    iv_hp INT CHECK (iv_hp >= 0),
    iv_atk INT CHECK (iv_atk >= 0),
    iv_def INT CHECK (iv_def >= 0),
    iv_sp_atk INT CHECK (iv_sp_atk >= 0),
    iv_sp_def INT CHECK (iv_sp_def >= 0),
    iv_speed INT CHECK (iv_speed >= 0),
    pok_id INT,
    PRIMARY KEY (pok_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id)
);

-- Create EFFORT VALUES table
CREATE TABLE EFFORT_VALUES (
    ev_hp INT CHECK (ev_hp >= 0 AND ev_hp <= 252),
    ev_atk INT CHECK (ev_atk >= 0 AND ev_atk <= 252),
    ev_def INT CHECK (ev_def >= 0 AND ev_def <= 252),
    ev_sp_atk INT CHECK (ev_sp_atk >= 0 AND ev_sp_atk <= 252),
    ev_sp_def INT CHECK (ev_sp_def >= 0 AND ev_sp_def <= 252),
    ev_speed INT CHECK (ev_speed >= 0 AND ev_speed <= 252),
    pok_id INT,
    PRIMARY KEY (pok_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    CHECK (ev_hp + ev_atk + ev_def + ev_sp_atk + ev_sp_def + ev_speed <= 510)
);