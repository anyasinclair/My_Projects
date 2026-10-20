CREATE SCHEMA games;

-- Import tables 1,2,3--

-- Confirm length/ uniqueness/ not null --
SELECT game_id, COUNT(*)
FROM games_description
GROUP BY game_id
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM games_description
WHERE game_id IS NULL;

SELECT MAX(LENGTH(game_id)) AS MaxLengthOfData
FROM games_description;

SELECT game_id
FROM games_description;

-- Alter table to enable use of game_id as primary key --

ALTER TABLE games_description
CHANGE COLUMN game_id game_id VARCHAR(10) NOT NULL ,
ADD PRIMARY KEY (game_id);

ALTER TABLE games_revenue
CHANGE COLUMN game_id game_id VARCHAR(10) NOT NULL ,
ADD CONSTRAINT fk_group
FOREIGN KEY (game_id) REFERENCES games_description (game_id);

ALTER TABLE games_reviews
CHANGE COLUMN game_id game_id VARCHAR(10) NOT NULL ,
ADD CONSTRAINT fk_group1
FOREIGN KEY (game_id) REFERENCES games_description (game_id);


-- Task 3 question 2 --
SELECT *
FROM games_reviews;

SELECT SUM(number_of_reviews_from_purchased_people)
FROM games_reviews;

SELECT SUM(Number_of_Purchases)
FROM games_revenue;

SELECT
SUM(number_of_reviews_from_purchased_people)
/ (SELECT SUM(Number_of_Purchases)FROM games_revenue) AS ReviewPercentage 
FROM games_reviews;

-- Task 3 question 3 --
SELECT 
SUM(number_of_english_reviews) / (SELECT SUM(number_of_reviews_from_purchased_people) FROM games_reviews)
AS PercentageEnglish
FROM games_reviews;

-- make a note -- need to have each game - reach out on how we want to display this -- 
SELECT  game_name, 
(number_of_english_reviews/number_of_reviews_from_purchased_people) * 100
AS PercentageEnglish
FROM games_reviews;


SELECT  game_name, 
number_of_english_reviews, number_of_reviews_from_purchased_people
FROM games_reviews;



SELECT *
FROM games_reviews
INNER JOIN games_description
ON games_reviews.game_id = games_description.game_id;


-- TASK 3 question 4 -- ALSO Covers part of question 1/ exploration.
SELECT*
FROM games_revenue;

SELECT Publisher, game_name, year_released, genre, number_of_Purchases * Unit_Price AS 'Revenue'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id
ORDER BY Revenue DESC
LIMIT 5;

SELECT Publisher, game_name, year_released, genre, number_of_Purchases * Unit_Price AS 'Revenue'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id
WHERE Publisher = 'Valve';

SELECT Publisher, game_name, year_released, genre, number_of_Purchases * Unit_Price AS 'Revenue'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id;

SELECT Publisher, SUM(number_of_Purchases * Unit_Price) AS 'TotalRevenue'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id
GROUP BY Publisher
ORDER BY TotalRevenue DESC
LIMIT 5;

SELECT *
FROM games_description
WHERE Publisher = 'unknown';


-- NOTE THAT ALL 5 top grossing games are ACTION -- 

-- TASK 4
-- Rank by revenue in each genre -- 
SELECT game_name, genre, publisher, number_of_Purchases * Unit_Price AS 'Revenue',
RANK () OVER (PARTITION BY games_description.genre ORDER BY (number_of_Purchases * Unit_Price) DESC) AS 'Rank'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id;


-- RANK by reviews in each genre
SELECT* 
FROM games_reviews;

SELECT games_description.game_name, genre, publisher, number_of_reviews_from_purchased_people,
RANK () OVER (PARTITION BY games_description.genre ORDER BY number_of_reviews_from_purchased_people DESC) AS 'Rank'
FROM games_reviews
INNER JOIN games_description
ON games_reviews.game_id = games_description.game_id;

-- Year released and impact on the data -- 

SELECT year_released, game_name, genre, publisher, number_of_Purchases * Unit_Price AS 'Revenue',
RANK () OVER (PARTITION BY games_description.year_released ORDER BY (number_of_Purchases * Unit_Price) DESC) AS 'Rank'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id;

SELECT year_released, game_name, genre, publisher, number_of_Purchases * Unit_Price AS 'Revenue',
RANK () OVER (PARTITION BY games_description.publisher ORDER BY (number_of_Purchases * Unit_Price) DESC) AS 'Rank'
FROM games_revenue
INNER JOIN games_description
ON games_revenue.game_id = games_description.game_id;


-- Additional insights
SELECT length(game_name)
FROM games_reviews;

SELECT*
FROM games_description
WHERE publisher = "KRAFTON";

SELECT*
FROM games_description
WHERE publisher = "SEGA";


-- Calculate total revenue for each game: Total Revenue = Number_of_Purchases * Unit_Price 

SELECT 

    game_id, 

    number_of_purchases, 

    unit_price, 

    (number_of_purchases * unit_price) AS total_revenue 

FROM games_revenue; 

  

 -- What are the top 5 games by revenue? 
SELECT 

    game_id, 

    number_of_purchases, 

    unit_price, 

    (number_of_purchases * unit_price) AS total_revenue 

FROM games_revenue 

ORDER BY total_revenue DESC 

LIMIT 5; 

  

-- Identify the top 3 genres by total revenue. 
 SELECT 

    d.genre, 

    SUM(r.Number_of_Purchases * r.Unit_Price) AS total_revenue 

FROM games_revenue r 

JOIN games_description d 

    ON r.game_id = d.game_id 

GROUP BY d.genre 

ORDER BY total_revenue DESC; 

  

-- Which year generated most of the revenue in the company. 

SELECT 

    d.year_released AS year, 

    SUM(r.Number_of_Purchases * r.Unit_Price) AS total_revenue 

FROM games_description d 

JOIN games_revenue r 

    ON d.game_id = r.game_id 

GROUP BY d.year_released 

ORDER BY total_revenue DESC 

LIMIT 1; 

-- Engagement Ratios 

-- Q8 

-- Calculate the percentage of Helpful and Funny tags to total reviews. 

 SELECT  

(SUM(gr.Helpful) / SUM(gr.number_of_reviews_from_purchased_people))*100 AS helpful_pct,  

(SUM(gr.Funny) / SUM(gr.number_of_reviews_from_purchased_people))*100 AS funny_pct 

 FROM games_reviews gr ; 

 

-- Which games and genres have the highest and lowest percentages? 

WITH game_stats AS ( 

SELECT  

gr.game_name AS name, 

    'Game' AS type, 

    SUM(gr.Helpful) * 100.0 / NULLIF(SUM(gr.number_of_reviews_from_purchased_people), 0) AS helpful_pct, 

    SUM(gr.Funny) * 100.0 / NULLIF(SUM(gr.number_of_reviews_from_purchased_people), 0) AS funny_pct 

  FROM games_reviews gr 

  GROUP BY gr.game_name), 

  

genre_stats AS ( 

  SELECT  

    d.genre AS name, 

    'Genre' AS type, 

    SUM(gr.Helpful) * 100.0 / NULLIF(SUM(gr.number_of_reviews_from_purchased_people), 0) AS helpful_pct, 

    SUM(gr.Funny) * 100.0 / NULLIF(SUM(gr.number_of_reviews_from_purchased_people), 0) AS funny_pct 

  FROM games_reviews gr 

  JOIN games_description d 

    ON gr.game_id = d.game_id 

  GROUP BY d.genre), 

 all_stats AS ( 

  SELECT * FROM game_stats 

  UNION ALL 

  SELECT * FROM genre_stats 

) 

, 

ranked AS ( 

  SELECT *, 

    RANK() OVER (PARTITION BY type ORDER BY helpful_pct DESC) AS max_helpful, 

    RANK() OVER (PARTITION BY type ORDER BY helpful_pct ASC) AS min_helpful, 

    RANK() OVER (PARTITION BY type ORDER BY funny_pct DESC) AS max_funny, 

    RANK() OVER (PARTITION BY type ORDER BY funny_pct ASC) AS min_funny 

  FROM all_stats) 

SELECT  

  type, 

  name, 

  helpful_pct, 

  funny_pct, 

  CASE  

    WHEN max_helpful = 1 THEN 'Highest Helpful' 

    WHEN min_helpful = 1 THEN 'Lowest Helpful' 

    WHEN max_funny = 1 THEN 'Highest Funny' 

    WHEN min_funny = 1 THEN 'Lowest Funny' 

  END AS category 

FROM ranked ; 

 

     -- Task 4.  Advanced SQL: Window Functions 

 

WITH game_metrics AS ( 

SELECT  

gr.game_id,grv.game_name, 

-- Total Revenue 

SUM(gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue, 

-- Total Reviews 

SUM(grv.number_of_reviews_from_purchased_people) AS total_reviews 

FROM games_revenue gr 

JOIN games_reviews grv 

ON gr.game_id = grv.game_id 

GROUP BY gr.game_id,grv.game_name 

) 

SELECT  

game_id,game_name, 

total_revenue, 

total_reviews, 

-- Rank by Revenue within Genre 

RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank, 

-- Rank by Reviews within Genre 

RANK() OVER ( ORDER BY total_reviews DESC) AS review_rank 

FROM game_metrics ; 

 

-- Use RANK() to rank games by their total revenue within each genre.  

-- Use RANK() to rank games by their total reviews within each genre. 

-- Rank by revenue in each genre --  
SELECT game_name, genre, publisher, number_of_Purchases * Unit_Price AS 'Revenue', 
RANK () OVER (PARTITION BY games_description.genre ORDER BY (number_of_Purchases * Unit_Price) DESC) AS 'Rank' 
FROM games_revenue 
INNER JOIN games_description 
ON games_revenue.game_id = games_description.game_id; 

-- RANK by reviews in each genre 
SELECT*  
FROM games_reviews; 

SELECT games_description.game_name, genre, publisher, number_of_reviews_from_purchased_people, 
RANK () OVER (PARTITION BY games_description.genre ORDER BY number_of_reviews_from_purchased_people DESC) AS 'Rank' 
FROM games_reviews 
INNER JOIN games_description 
ON games_reviews.game_id = games_description.game_id; 
