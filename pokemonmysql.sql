SELECT 
    *
FROM
    pokemon_stats.pokemon;

SELECT *
FROM pokemon
WHERE `Name` LIKE '%Mega%'
AND Legendary = 'True'
;
-- There are only 6 Mega legendary pokemon
-- All have Total Stats of 700 to 780


SELECT *, ROW_NUMBER () OVER (
PARTITION BY `Name`) AS row_num
FROM pokemon;


-- Create a duplicate table for further analysis
CREATE TABLE `pokemon2` (
  `#` text,
  `Name` text,
  `Type 1` text,
  `Type 2` text,
  `Total` int DEFAULT NULL,
  `HP` int DEFAULT NULL,
  `Attack` int DEFAULT NULL,
  `Defense` int DEFAULT NULL,
  `Sp. Atk` int DEFAULT NULL,
  `Sp. Def` int DEFAULT NULL,
  `Speed` int DEFAULT NULL,
  `Generation` text,
  `Legendary` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT 
    *
FROM
    pokemon_stats.pokemon2;

INSERT INTO pokemon2
SELECT 
    *
FROM
    pokemon;

SELECT *
FROM pokemon2;

SELECT ROW_NUMBER () OVER(
	PARTITION BY `Name`) AS row_num
FROM pokemon2;

-- This CTE query will return any rows that have duplicates

WITH poke_duplicate_cte AS
	(SELECT *,
    ROW_NUMBER () OVER(
	PARTITION BY `Name`) AS row_num
    FROM pokemon2
    )
SELECT *
FROM poke_duplicate_cte
WHERE row_num > 1;

-- No duplicates returned!


-- Lets change Blanks to NULL

UPDATE pokemon2
SET `Type 2` = NULL
WHERE `Type 2` = ''
;

SELECT *
FROM pokemon2;



-- Lets begin some EDA
-- Now lets find how many pokemon only have 1 Type and how many only have 2 Types

SELECT *
FROM pokemon2
WHERE `Type 2` IS NULL;

-- 386 Rows are returned where Pokemon only have Type 1

SELECT *
FROM pokemon2
WHERE `Type 2` IS NOT NULL;

-- 414 Rows are returned where Pokemon have Type 1 and Type 2

SELECT `#`, `Name`, Generation
FROM pokemon2
WHERE Generation BETWEEN 1 AND 2;

-- 272 Pokemon in Generations 1 and 2

-- Returns a Table with Attack vs Average Attack and Speed vs Average Speed. Then filtered for pokemon with above average Attack and Speed. Ordered by Generation - Attack - Speed
WITH poke_attack AS
(SELECT `#`,`Name`, Generation, Attack, AVG(Attack) OVER() AS Avg_Attack, Speed, AVG(Speed) OVER () AS Avg_Speed
FROM  pokemon2
GROUP BY `#`, `Name`, Generation, Attack, Speed
)
SELECT *
FROM poke_attack
WHERE Attack > 79.0013 AND Speed > 68.2775
ORDER BY Generation, Attack, Speed;

-- This Returns the Pokemon Names and Attack powers along with columns that showcase the highest, lowest, and average attack power.
SELECT 
    `Name`,
    Attack,
    (SELECT 
            MAX(Attack)
        FROM
            pokemon2) AS Strongest_Attack,
    (SELECT 
            MIN(Attack)
        FROM
            pokemon2) AS Weakest_Attack,
    (SELECT 
            AVG(Attack)
        FROM
            pokemon2) AS Average_Attack
FROM
    pokemon2
ORDER BY Attack DESC;


SELECT *
FROM pokemon2;

-- This will return pokemon wit a higher defense than attack (298)
SELECT `Name`, Attack/Defense, Attack, Defense
FROM pokemon2
WHERE Attack/Defense <= 0.9999
;

-- This returns pokemon with attack higher than defense
SELECT `Name`, Attack/Defense, Attack, Defense
FROM pokemon2
WHERE Attack/Defense > 1.0000
;

-- This returns Pokemon that have equal attack and defense (69)
SELECT `Name`, Attack/Defense, Attack, Defense
FROM pokemon2
WHERE Attack/Defense = 1.0000
;


SELECT *
FROM pokemon2;


SELECT AVG(Total)
FROM pokemon2;


-- This will return Pokemon with Total Stats above average of Total Stats
SELECT 
    `#`,
    `Name`,
    Total,
    (SELECT 
            AVG(Total)
        FROM
            pokemon2) AS Avg_Total
FROM
    pokemon2
WHERE
    Total > 435.1025
;



-- Returns the Average Total Stats by Generation (Generation 4 is the highest and 2 is the lowest average)
SELECT DISTINCT Generation, AVG(Total) OVER(PARTITION BY Generation) AS Average_By_Generation
FROM pokemon2
ORDER BY Average_By_Generation DESC;



-- This creates a Procedure with Pokemon names and numbers along with their Total Stat Points and Average Total Stat Points By Generation
CREATE PROCEDURE Average_Total_By_Generation_Procedure ()
SELECT DISTINCT p1.`#`, p1.`Name`, p1.Generation, p1.Total, 
AVG(p1.Total) OVER (PARTITION BY p1.Generation) AS Average_By_Generation
FROM pokemon2 p1
JOIN pokemon2 p2
	ON p1.`#` = p2.`#`
ORDER BY p1.Total DESC
;

-- This Calls the Procedure that was just created
CALL Average_Total_By_Generation_Procedure ()
;


-- This creates a Temporary Table containing all Mega Pokemon without Regular Pokemon that have mega in their names (48 Mega Pokemon exist at this time)

CREATE TEMPORARY TABLE Mega_Pokemon
SELECT *
FROM pokemon2
WHERE `Name` LIKE '%Mega %';

SELECT *
FROM Mega_Pokemon;


-- This creates a Permanent Table containing the same data from our temporary table (Did this because it seems like useful information we would want to have on hand)
CREATE TABLE mega_Pokemon
SELECT *
FROM pokemon2
WHERE `Name` LIKE '%Mega %';


-- Here we find that there are only 6 Legendary Pokemon Forms (Two of which belong to Mewtwo)(Generation 2, 4, and 5 have no Legendary Pokemon with Mega forms)
SELECT *
FROM mega_pokemon
WHERE Legendary = 'TRUE';






