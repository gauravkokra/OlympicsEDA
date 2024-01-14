-- We are creating the table so that we can load the Data Set File.
-- The typical Data import wizard takes time to load if the file size is big.
-- We have directly saved the CSV in the database folder and then loaded it into MySQL. It took a maximum of 3 seconds which otherwise took 2 hours. 

CREATE TABLE Olympics1 (
	ID int,
    Name VARCHAR(255),
    Sex VARCHAR(255),
    Age VARCHAR(255),
    Height VARCHAR(255),
    Weight VARCHAR(255),
    Team VARCHAR(255),
    NOC VARCHAR(255),
    Games VARCHAR(255), 
    Year VARCHAR(255),
    Season VARCHAR(255), 
    City VARCHAR(255),
    Sport VARCHAR(255),
    Event VARCHAR(255),
    Medal VARCHAR(255)
    );
    
LOAD DATA INFILE 'athlete_events.csv'
INTO TABLE olympics1
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM olympics1;

#1. How many olympics games have been held?

	-- To find this answer we will have to see distinct values in the column games.

	SELECT count(DISTINCT Games) 
	FROM olympics1;

	-- 51 games have been held.

# 2. List down all Olympics games held so far.

	SELECT DISTINCT Games 
    FROM olympics1;
    
# 3.Mention the total no of nations who participated in each olympics game?
	SELECT * FROM olympics1
    WHERE Team = 'Thessalonki-1';
    
    SELECT DISTINCT Team
    FROM olympics1;
    
    -- The above will give the total teams and we can have different teams from a single country playing multiple games.
    -- NOC is a committee which is present only single for each country.(National Olympic committee)
    
    SELECT count(DISTINCT NOC)
    FROM olympics1;

	
# 4. Which year saw the highest and lowest no of countries participating in olympics?
SELECT * FROM olympics1;

	SELECT * 
    FROM (
		
        SELECT Year, COUNT(DISTINCT NOC) AS Participation
		FROM olympics1
		GROUP BY Year
		ORDER BY Participation DESC
		LIMIT 1) AS CTE11
    
	UNION

    SELECT * 
    FROM (
		SELECT Year, COUNT(DISTINCT NOC) AS Participation
		FROM olympics1
		GROUP BY Year
		ORDER BY Participation ASC
		LIMIT 1
		) AS CTE2;
        
        
-- The above code is written so that we can display both max and minimum together
-- Another way of displaying the min max participation is the following

		SELECT Year, count(DISTINCT NOC) AS Participation
		FROM olympics1
		GROUP BY Year
        HAVING Participation = (
			SELECT MAX(Participation) 
				FROM (
					SELECT Year, count(DISTINCT NOC) AS Participation
					FROM olympics1
					GROUP BY Year
					ORDER BY Participation DESC
					) AS MaxTable
								)
			AND
            
            Participation = (
            SELECT MIN(Participation) 
            FROM (
				SELECT Year, count(DISTINCT NOC) AS Participation
				FROM olympics1
				GROUP BY Year
				ORDER BY Participation DESC
                ) AS MinTable
							);
                
    
SET sql_mode = 'only_full_group_by';
SET sql_mode = '';

    
# 5. Which nation has participated in all of the olympic games?
SELECT * FROM olympics1;
                
SELECT NOC, count(DISTINCT Games) AS No_Of_Games
FROM olympics1
GROUP BY NOC
HAVING No_Of_Games IN (SELECT  count(DISTINCT games) FROM olympics1);                


# 6. Identify the sport which was played in all summer olympics.
SELECT DISTINCT Sport FROM olympics1;

SELECT DISTINCT Sport,Season
FROM olympics1
WHERE Season = 'Summer';



# 7. Which Sports were just played only once in the olympics?

SELECT * FROM olympics1;

SELECT Sport, count(DISTINCT Games) AS Num
FROM olympics1
GROUP BY SPORT
HAVING Num = 1
ORDER BY Num;

# 8. Fetch the total no of sports played in each olympic games.
SELECT * FROM olympics1;

SELECT games,count(DISTINCT Sport)
FROM olympics1
GROUP BY games;

# 9. Fetch details of the oldest athletes to win a gold medal.

SELECT * 
FROM olympics1;

-- The age column type is of VARCHAR and we need to update the ages of the players as 0 as we dont have any details regarding them.

SET SQL_SAFE_UPDATES = 0;

-- Updating the columns where we have age equal to NA and then updating them to 0

UPDATE olympics1
SET Age = 0
WHERE Age = 'NA';

-- Now we need to update the column type to integer

ALTER TABLE olympics1
MODIFY COLUMN Age int;

SELECT DISTINCT Medal
FROM olympics1;

SELECT *
FROM olympics1
WHERE Medal LIKE '%Gold%'
ORDER BY Age DESC;

#10. Find the Ratio of male and female athletes participated in all olympic games.
SELECT * FROM olympics1;

SELECT DISTINCT Games
FROM olympics1;

SELECT Games,
	   Male_Count,
       Female_Count,
       (CASE WHEN Female_Count = 0 THEN 'No Females Participated' 
       ELSE Male_Count/Female_Count END) AS Sex_Ratio
       
FROM (

		SELECT
			Games,
			COUNT(CASE WHEN Sex = 'M' THEN 1 END) AS Male_Count,
			COUNT(CASE WHEN Sex = 'F' THEN 1 END) AS Female_Count
		FROM
			olympics1
		GROUP BY
			Games
		) AS Sex_Ratio_Table;
    


# 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT * FROM olympics1;

SELECT Name,count(Medal) AS MedalsWon
FROM olympics1
WHERE Medal LIKE '%Gold%'
GROUP BY Name
ORDER BY MedalsWon DESC
LIMIT 5;

# 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT * FROM olympics1;

SELECT Name,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT Name,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY Name
) AS TotalMedals

ORDER BY TotalMedalsWon;

-- No output is coming even after solving the inner query seperately. APOLOGIES!!!! 

#13.  Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

-- The solution is same as above. Instead of Name we have used NOC and LIMIT has been set to 5 rows

SELECT * FROM olympics1;

SELECT NOC,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT NOC,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY NOC
) AS TotalMedals

ORDER BY TotalMedalsWon DESC
LIMIT 5;

# 14. List down total gold, silver and broze medals won by each country.

SELECT NOC,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT NOC,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY NOC
) AS TotalMedals

ORDER BY TotalMedalsWon DESC;


SELECT * FROM olympics1;

#15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

SELECT * FROM olympics1;

SELECT NOC,
	   Games,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT NOC,
			   Games,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY NOC,Games
) AS TotalMedals

ORDER BY 1,2 ;

# 16.  Identify which country won the most gold, most silver and most bronze medals in each olympic games.

SELECT * FROM olympics1;

-- Country which won the most gold in each olympic game

		SELECT Games,NOC,count(Medal) AS GoldCount
		FROM olympics1
		WHERE Medal LIKE '%Gold%'
		GROUP BY 1,2
		ORDER BY GoldCount DESC;

-- Country which won the most Silvers in each olympic game

		SELECT Games,NOC,count(Medal) AS SilverCount
		FROM olympics1
		WHERE Medal LIKE '%Silver%'
		GROUP BY 1,2
		ORDER BY SilverCount DESC; 
        
-- Country which one the most Bronzes in each olympic game

		SELECT Games,NOC,count(Medal) AS BronzeCount
		FROM olympics1
		WHERE Medal LIKE '%Bronze%'
		GROUP BY 1,2
		ORDER BY BronzeCount DESC;

# 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

SELECT * FROM olympics1;

-- Identifying the most total medals one in each olympic games

SELECT Games,
	   NOC,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT Games,
			   NOC,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY Games,NOC
) AS TotalMedals

ORDER BY TotalMedalsWon DESC;


# 18. Which countries have never won gold medal but have won silver/bronze medals?

SELECT * FROM olympics1;

SELECT Games,
	   NOC,
	   GoldsWon,
       SilversWon,
       BronzesWon,
       (GoldsWon+SilversWon+BronzesWon) AS TotalMedalsWon
       
FROM (
		SELECT Games,
			   NOC,
			   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldsWon,
			   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilversWon,
			   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzesWon
		FROM olympics1
		GROUP BY Games,NOC
) AS TotalMedals

WHERE GoldsWon = 0 AND SilversWon != 0 AND BronzesWon != 0

ORDER BY TotalMedalsWon DESC;


#19.  In which Sport/event, India has won highest medals.

-- This means that we have to find in which games has India won the highest number of Medals. 

SELECT * FROM olympics1;

SELECT NOC,
	   Sport,
       TotalMedals,
       Ranking

FROM (
		SELECT NOC,
			   Sport,
			   TotalMedals,
			   RANK () OVER (PARTITION BY Sport ORDER BY TotalMedals DESC) As Ranking
		FROM (
			SELECT NOC,
				   Sport,
				   (GoldMedals+SilverMedals+BronzeMedals) AS TotalMedals
			FROM (
					SELECT NOC,
						   Sport,
						   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldMedals,
						   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilverMedals,
						   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzeMedals
					FROM olympics1
					GROUP BY NOC,Sport
				  ) AS FinalTable
				  
			ORDER BY NOC,Sport
			  ) AS FinalTable1
		) AS FinalTable2
WHERE NOC = 'IND' AND Ranking = 1;

-- In the above query we are trying to find out that particular sport where India has ranked 1 in the total number of medals recieved. 
-- Trying the question again. 

					SELECT NOC,
						   Sport,
				           (GoldMedals+SilverMedals+BronzeMedals) AS TotalMedals
					FROM (
							SELECT NOC,
								   Sport,
								   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldMedals,
								   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilverMedals,
								   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzeMedals
							FROM olympics1
							GROUP BY NOC,Sport
						  ) AS FinalTable
					WHERE NOC = 'IND'
                    ORDER BY TotalMedals DESC;

# 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
SELECT * FROM olympics1;
					SELECT sum(TotalMedals)
                    FROM (
					SELECT NOC,
						   Games,
						   Sport,
				           (GoldMedals+SilverMedals+BronzeMedals) AS TotalMedals
					FROM (
							SELECT NOC,
								   Games,
								   Sport,
								   COUNT(CASE WHEN Medal LIKE '%Gold%' THEN 1 END) AS GoldMedals,
								   COUNT(CASE WHEN Medal LIKE '%Silver%' THEN 1 END) AS SilverMedals,
								   COUNT(CASE WHEN Medal LIKE '%Bronze%' THEN 1 END) AS BronzeMedals
							FROM olympics1
							GROUP BY NOC,Games,Sport
						  ) AS FinalTable
					WHERE NOC = 'IND' AND Sport = 'Hockey'
                    ORDER BY TotalMedals DESC) AS FinalTable22;
