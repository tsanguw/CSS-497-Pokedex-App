-- Drop tables if they exist
DROP TABLE IF EXISTS MOVE_HAS_STATUS_EFFECT;
DROP TABLE IF EXISTS POKEMON_EXHIBIT_A_NATURE;
DROP TABLE IF EXISTS POKEMON_BEARS_TYPE;
DROP TABLE IF EXISTS POKEMON_INHABITS_HABITAT;
DROP TABLE IF EXISTS POKEMON_POSSESSES_ABILITY;
DROP TABLE IF EXISTS TYPE_EFFICACY;
DROP TABLE IF EXISTS MOVESET;
DROP TABLE IF EXISTS EVOLUTION;
DROP TABLE IF EXISTS MOVE;
DROP TABLE IF EXISTS STATUS_EFFECT;
DROP TABLE IF EXISTS NATURE;
DROP TABLE IF EXISTS TYPE;
DROP TABLE IF EXISTS GENERATION;
DROP TABLE IF EXISTS METHOD;
DROP TABLE IF EXISTS HABITAT;
DROP TABLE IF EXISTS ABILITIES;
DROP TABLE IF EXISTS POKEMON;

-- Create POKEMON table
CREATE TABLE POKEMON (
    pok_id INT PRIMARY KEY,
    pok_name VARCHAR(50) NOT NULL,
    pok_height FLOAT CHECK (pok_height >= 0),
    pok_weight FLOAT CHECK (pok_weight >= 0),
    pok_base_exp INT CHECK (pok_base_exp >= 0),
    pok_ev INT CHECK (pok_ev >= 0)
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

-- Create METHOD table
CREATE TABLE METHOD (
    method_id INT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE
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
    nat_name VARCHAR(50) NOT NULL UNIQUE
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
    pre_evol_pok_id INT,
    evol_pok_id INT,
    evol_min_lvl INT CHECK (evol_min_lvl >= 0),
    PRIMARY KEY (pok_id, pre_evol_pok_id, evol_pok_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (pre_evol_pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (evol_pok_id) REFERENCES POKEMON(pok_id)
);

-- Create MOVE table
CREATE TABLE MOVE (
    move_id INT PRIMARY KEY,
    type_id INT,
    move_name VARCHAR(50) NOT NULL UNIQUE,
    move_pp INT CHECK (move_pp >= 0),
    move_power INT CHECK (move_power >= 0),
    move_accuracy FLOAT CHECK (move_accuracy >= 0 AND move_accuracy <= 100),
    FOREIGN KEY (type_id) REFERENCES TYPE(type_id)
);

-- Create MOVESET table
CREATE TABLE MOVESET (
    pok_id INT,
    gen_id INT,
    move_id INT,
    method_id INT,
    learn_level INT CHECK (learn_level >= 0),
    PRIMARY KEY (pok_id, gen_id, move_id, method_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (gen_id) REFERENCES GENERATION(gen_id),
    FOREIGN KEY (move_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (method_id) REFERENCES METHOD(method_id)
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

-- Create POKEMON INHABITS HABITAT table
CREATE TABLE POKEMON_INHABITS_HABITAT (
    pok_id INT,
    hab_id INT,
    PRIMARY KEY (pok_id, hab_id),
    FOREIGN KEY (pok_id) REFERENCES POKEMON(pok_id),
    FOREIGN KEY (hab_id) REFERENCES HABITAT(hab_id)
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

-- Create MOVE HAS STATUS EFFECT table
CREATE TABLE MOVE_HAS_STATUS_EFFECT (
    move_id INT,
    stat_id INT,
    effect_chance FLOAT CHECK (effect_chance >= 0 AND effect_chance <= 100),
    PRIMARY KEY (move_id, stat_id),
    FOREIGN KEY (move_id) REFERENCES MOVE(move_id),
    FOREIGN KEY (stat_id) REFERENCES STATUS_EFFECT(stat_id)
);
