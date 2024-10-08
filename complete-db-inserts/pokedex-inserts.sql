-- Inserts for TABLE: TYPES
INSERT INTO TYPE (type_id, type_name) VALUES (1, 'normal');
INSERT INTO TYPE (type_id, type_name) VALUES (2, 'fighting');   
INSERT INTO TYPE (type_id, type_name) VALUES (3, 'flying');     
INSERT INTO TYPE (type_id, type_name) VALUES (4, 'poison');     
INSERT INTO TYPE (type_id, type_name) VALUES (5, 'ground');     
INSERT INTO TYPE (type_id, type_name) VALUES (6, 'rock');       
INSERT INTO TYPE (type_id, type_name) VALUES (7, 'bug');        
INSERT INTO TYPE (type_id, type_name) VALUES (8, 'ghost');      
INSERT INTO TYPE (type_id, type_name) VALUES (9, 'steel');      
INSERT INTO TYPE (type_id, type_name) VALUES (10, 'fire');      
INSERT INTO TYPE (type_id, type_name) VALUES (11, 'water');     
INSERT INTO TYPE (type_id, type_name) VALUES (12, 'grass');     
INSERT INTO TYPE (type_id, type_name) VALUES (13, 'electric');  
INSERT INTO TYPE (type_id, type_name) VALUES (14, 'psychic');   
INSERT INTO TYPE (type_id, type_name) VALUES (15, 'ice');       
INSERT INTO TYPE (type_id, type_name) VALUES (16, 'dragon');    
INSERT INTO TYPE (type_id, type_name) VALUES (17, 'dark');      
INSERT INTO TYPE (type_id, type_name) VALUES (18, 'fairy');     
INSERT INTO TYPE (type_id, type_name) VALUES (19, 'stellar');   
INSERT INTO TYPE (type_id, type_name) VALUES (10001, 'unknown');
-- Inserts for TABLE: HABITATS
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (1, 'cave', '');
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (2, 'forest', '');       
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (3, 'grassland', '');    
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (4, 'mountain', '');     
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (5, 'rare', '');
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (6, 'rough-terrain', '');
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (7, 'sea', '');
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (8, 'urban', '');        
INSERT INTO HABITAT (hab_id, hab_name, hab_desc) VALUES (9, 'waters-edge', '');  
-- Inserts for TABLE: EVOL_METHODS
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (1, 'level-up');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (2, 'trade');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (3, 'use-item');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (4, 'shed');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (5, 'spin');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (6, 'tower-of-darkness');  
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (7, 'tower-of-waters');    
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (8, 'three-critical-hits');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (9, 'take-damage');        
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (10, 'other');
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (11, 'agile-style-move');  
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (12, 'strong-style-move'); 
INSERT INTO EVOLUTION_METHOD (evol_method_id, evol_method_name) VALUES (13, 'recoil-damage');     
-- Inserts for TABLE: MOVE_METHODS
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (1, 'level-up');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (2, 'egg');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (3, 'tutor');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (4, 'machine');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (5, 'stadium-surfing-pikachu');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (6, 'light-ball-egg');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (7, 'colosseum-purification');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (8, 'xd-shadow');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (9, 'xd-purification');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (10, 'form-change');
INSERT INTO MOVE_METHOD (move_method_id, move_method_name) VALUES (11, 'zygarde-cube');
-- Inserts for TABLE: GENERATIONS
INSERT INTO GENERATION (gen_id, gen_name) VALUES (1, 'generation-i');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (2, 'generation-ii');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (3, 'generation-iii');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (4, 'generation-iv');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (5, 'generation-v');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (6, 'generation-vi');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (7, 'generation-vii');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (8, 'generation-viii');
INSERT INTO GENERATION (gen_id, gen_name) VALUES (9, 'generation-ix');
-- Inserts for TABLE: NATURES
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (1, 'hardy', '', '');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (2, 'bold', 'defense', 'attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (3, 'modest', 'special-attack', 'attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (4, 'calm', 'special-defense', 'attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (5, 'timid', 'speed', 'attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (6, 'lonely', 'attack', 'defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (7, 'docile', '', '');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (8, 'mild', 'special-attack', 'defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (9, 'gentle', 'special-defense', 'defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (10, 'hasty', 'speed', 'defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (11, 'adamant', 'attack', 'special-attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (12, 'impish', 'defense', 'special-attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (13, 'bashful', '', '');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (14, 'careful', 'special-defense', 'special-attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (15, 'rash', 'special-attack', 'special-defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (16, 'jolly', 'speed', 'special-attack');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (17, 'naughty', 'attack', 'special-defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (18, 'lax', 'defense', 'special-defense');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (19, 'quirky', '', '');
INSERT INTO NATURE (nat_id, nat_name, nat_increase, nat_decrease) VALUES (20, 'naive', 'speed', 'special-defense');
-- Inserts for TABLE: STATUS_EFFECTS
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (-1, 'unknown', '????');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (0, 'none', 'Aucun');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (1, 'paralysis', 'Paralysie');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (2, 'sleep', 'Sommeil');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (3, 'freeze', 'Gel');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (4, 'burn', 'Brûlure');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (5, 'poison', 'Empoisonnement');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (6, 'confusion', 'Confusion');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (7, 'infatuation', 'Attraction');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (8, 'trap', 'Piège');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (9, 'nightmare', 'Cauchemar');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (12, 'torment', 'Tourmente');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (13, 'disable', 'Entrave');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (14, 'yawn', 'Bâillement');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (15, 'heal-block', 'Anti-Soin');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (17, 'no-type-immunity', 'Aucune immunité aux types');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (18, 'leech-seed', 'Vampigraine');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (19, 'embargo', 'Embargo');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (20, 'perish-song', 'Requiem');
INSERT INTO STATUS_EFFECT (stat_id, stat_name, stat_desc) VALUES (21, 'ingrain', 'Racines');
-- Inserts for TABLE: ITEM_CATEGORIES
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (1, 'stat-boosts');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (2, 'effort-drop');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (3, 'medicine');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (4, 'other');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (5, 'in-a-pinch');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (6, 'picky-healing');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (7, 'type-protection');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (8, 'baking-only');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (9, 'collectibles');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (10, 'evolution');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (11, 'spelunking');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (12, 'held-items');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (13, 'choice');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (14, 'effort-training');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (15, 'bad-held-items');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (16, 'training');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (17, 'plates');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (18, 'species-specific');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (19, 'type-enhancement');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (20, 'event-items');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (21, 'gameplay');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (22, 'plot-advancement');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (23, 'unused');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (24, 'loot');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (25, 'all-mail');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (26, 'vitamins');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (27, 'healing');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (28, 'pp-recovery');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (29, 'revival');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (30, 'status-cures');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (32, 'mulch');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (33, 'special-balls');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (34, 'standard-balls');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (35, 'dex-completion');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (36, 'scarves');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (37, 'all-machines');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (38, 'flutes');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (39, 'apricorn-balls');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (40, 'apricorn-box');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (41, 'data-cards');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (42, 'jewels');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (43, 'miracle-shooter');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (44, 'mega-stones');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (45, 'memories');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (46, 'z-crystals');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (47, 'species-candies');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (48, 'catching-bonus');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (49, 'dynamax-crystals');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (50, 'nature-mints');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (51, 'curry-ingredients');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (52, 'tera-shard');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (53, 'sandwich-ingredients');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (54, 'tm-materials');
INSERT INTO ITEM_CATEGORY (item_cat_id, item_cat_name) VALUES (55, 'picnic');
-- Inserts for TABLE: TYPE_EFFICACY
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (1, 6, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (1, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (1, 8, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 1, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 6, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 9, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 15, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 17, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 3, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 4, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 7, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 14, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 18, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (2, 8, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 2, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 7, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 12, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 6, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (3, 13, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 12, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 18, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 4, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 5, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 6, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 8, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (4, 9, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 4, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 6, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 9, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 10, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 13, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 7, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 12, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (5, 3, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 3, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 7, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 10, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 15, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 2, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 5, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (6, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 12, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 14, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 17, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 2, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 3, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 4, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 8, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 10, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (7, 18, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (8, 8, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (8, 14, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (8, 17, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (8, 1, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 6, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 15, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 18, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 10, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 11, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (9, 13, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 7, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 9, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 12, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 15, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 6, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 10, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 11, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (10, 16, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 5, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 6, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 10, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 11, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 12, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (11, 16, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 5, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 6, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 11, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 3, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 4, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 7, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 10, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 12, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (12, 16, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 3, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 11, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 12, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 13, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 16, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (13, 5, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (14, 2, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (14, 4, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (14, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (14, 14, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (14, 17, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 3, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 5, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 12, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 16, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 10, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 11, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (15, 15, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (16, 16, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (16, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (16, 18, 0.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (17, 8, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (17, 14, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (17, 2, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (17, 17, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (17, 18, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 2, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 16, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 17, 2.0);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 4, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 9, 0.5);
INSERT INTO TYPE_EFFICACY (type_id, target_type_id, dmg_factor) VALUES (18, 10, 0.5);

