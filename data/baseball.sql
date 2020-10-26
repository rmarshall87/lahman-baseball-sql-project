-- Question 1) DONE!!!

/*What range of years for baseball games played does the 
provided database cover?
*/

/*SELECT MIN(yearid),
		 MAX(yearid)
FROM teams;
*/

-- Question 2) DONE!!!

/*Cleaned up Clint code w/CTEs...how to replace teamid with franchise name?
Find the name and height of the shortest player in the database. How many
games did he play in? What is the name of the team for which he played?
*/

/*WITH games AS (SELECT g_all as games_played,appearances.playerid
			  	 FROM appearances)
,team AS (SELECT name,playerid
			  FROM teams INNER JOIN appearances
		  		ON teams.teamid=appearances.teamid)
SELECT height,namefirst,namelast,games_played,teamid
FROM people RIGHT JOIN games
	ON people.playerid=games.playerid
		RIGHT JOIN appearances ON people.playerid=appearances.playerid
			INNER JOIN team ON appearances.teamid=teams.teamid
ORDER BY height ASC;
*/

-- Alternative method, why is teamid working here?

/*WITH shortest_player AS (SELECT *
						FROM people
						ORDER BY height
						LIMIT 1),
sp_total_games AS (SELECT *
				  FROM shortest_player
				  LEFT JOIN appearances
				  USING(playerid))
SELECT DISTINCT(name), namelast, namefirst, height, g_all as games_played, sp_total_games.yearid
FROM sp_total_games
LEFT JOIN teams
USING(teamid);
*/

-- Question 3) Try using CTEs instead of method below...it works, but
-- just curious.

/*Find all players in the database who played at Vanderbilt University.
Create a list showing each player’s first and last names as well as 
the total salary they earned in the major leagues. Sort this list in 
descending order by the total salary earned. Which Vanderbilt player
earned the most money in the majors?*/

/*SELECT DISTINCT concat(p.namefirst, ' ', p.namelast) AS name, 
			    sc.schoolname,
  				SUM(sa.salary)
 				 OVER (PARTITION BY concat(p.namefirst, ' ', p.namelast))::numeric::money as total_salary
FROM (people p JOIN collegeplaying cp ON p.playerid = cp.playerid)
  				JOIN schools sc ON cp.schoolid = sc.schoolid
  					JOIN salaries sa ON p.playerid = sa.playerid
WHERE cp.schoolid = 'vandy'
GROUP BY name, schoolname, sa.salary, sa.yearid
ORDER BY total_salary DESC;
*/

-- Question 4) DONE!!!

/*Using the fielding table, group players into three groups based on 
their position: label players with position OF as "Outfield", those 
with position "SS", "1B", "2B", and "3B" as "Infield", and those
with position "P" or "C" as "Battery". Determine the number of 
putouts made by each of these three groups in 2016.*/

/*SELECT SUM(po) as put_out,
	   CASE WHEN pos='OF' THEN 'outfield'
	   	   	WHEN pos='1B' OR pos='2B' OR pos='3B' OR pos='SS' THEN 'infield'
	   	    ELSE 'battery' END AS position_group
FROM fielding
WHERE yearid=2016
GROUP BY position_group
ORDER BY SUM(po) DESC;
*/			

-- Question 5) Look deeper at these to fully understand.

/*Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places. Do the same for 
home runs per game. Do you see any trends?*/

/*SELECT yearid/10*10 as decade, 
	   ROUND(AVG(HR/g), 2) as avg_HR_per_game,
	   ROUND(AVG(so/g), 2) as avg_so_per_game
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER BY decade;
*/

--Alternate method using generate series
/*WITH decades AS (	
	SELECT 	generate_series(1920,2010,10) AS low_b,
			generate_series(1929,2019,10) AS high_b)
			
SELECT 	low_b AS decade,
		--SUM(so) as strikeouts,
		--SUM(g)/2 as games,  -- used last 2 lines to check that each step adds correctly
		ROUND(SUM(so::numeric)/(SUM(g::numeric)/2),2) as SO_per_game,  -- note divide by 2, since games are played by 2 teams
		ROUND(SUM(hr::numeric)/(sum(g::numeric)/2),2) as hr_per_game
FROM decades LEFT JOIN teams
	ON yearid BETWEEN low_b AND high_b
GROUP BY decade
ORDER BY decade;
*/

-- Question 6) From Clint

/*Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts 
which are successful. (A stolen base attempt results either in a 
stolen base or being caught stealing.) Consider only players who 
attempted at least 20 stolen bases.*/

/*SELECT DISTINCT(batting.playerid) as player, namefirst, namelast, teamid, SUM(cs+sb) as sb_attempts, SUM((sb::float/(sb::float+cs::float)))*100 AS sb_success, yearid
FROM batting
LEFT JOIN people
ON batting.playerid = people.playerid
WHERE yearid = '2016' AND cs > 0 AND sb > 0 AND (cs + sb)>=20
GROUP BY player, namefirst, namelast, yearid, teamid
ORDER BY sb_success desc
LIMIT 1;
*/

-- Alternate method
/*SELECT Concat(namefirst,' ',namelast), batting.yearid, ROUND(MAX(sb::decimal/(cs::decimal+sb::decimal))*100,2) as sb_success_percentage
FROM batting
INNER JOIN people on batting.playerid = people.playerid
WHERE yearid = '2016'
AND (sb+cs) >= 20
GROUP BY namefirst, namelast, batting.yearid
ORDER BY sb_success_percentage DESC;
*/

-- Question 7) From Mike

/*From 1970 – 2016, what is the largest number of wins for a team that
did not win the world series? What is the smallest number of wins 
for a team that did win the world series? Doing this will probably 
result in an unusually small number of wins for a world series 
champion – determine why this is the case. Then redo your query,
excluding the problem year. How often from 1970 – 2016 was it the 
case that a team with the most wins also won the world series? 
What percentage of the time?*/

--part1
/*SELECT yearid, 
	   SUM(w) AS wins, 
	   wswin, 
	   franchid
FROM teams
WHERE wswin IS NOT null
	AND wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY wswin, franchid, yearid
ORDER BY wins DESC;
--largest = SEA, 116 wins for 2001
*/

--part2
/*SELECT yearid, SUM(w) AS wins, wswin, franchid
FROM teams
WHERE wswin IS NOT null
	AND wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY wswin, franchid, yearid
ORDER BY wins;
*/
--smallest = TOR, 37 win for 1981

--part3
/*
SELECT yearid, SUM(w) as wins, wswin, franchid
FROM teams
WHERE wswin IS NOT null
	AND wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY wswin, franchid, yearid
ORDER BY wins;
*/
-- players strike in 1981

--part4
/*
WITH ws_winners AS (SELECT yearid,
						MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					AND wswin = 'Y'
					GROUP BY yearid
					INTERSECT
					SELECT yearid,
						MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					GROUP BY yearid
					ORDER BY yearid)
SELECT (COUNT(ws.yearid)/COUNT(t.yearid)::float)*100 AS percentage
FROM teams as t LEFT JOIN ws_winners AS ws ON t.yearid = ws.yearid
WHERE t.wswin IS NOT NULL
AND t.yearid BETWEEN 1970 AND 2016;
*/

-- Won WS and had most wins in regular season
/*SELECT yearid,
	MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 and 2016
AND wswin = 'Y'
GROUP BY yearid
INTERSECT
SELECT yearid,
	MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 and 2016
GROUP BY yearid
ORDER BY yearid;
*/

-- Question 8) DONE!!!

/*Using the attendance figures from the homegames table, find the teams
and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by
number of games). Only consider parks where there were at least 10 
games played. Report the park name, team name, and average attendance.
Repeat for the lowest 5 average attendance.
*/

-- Top 5 Average Attendance (change to ASC for bottom 5)
/*SELECT 
	   team,
	   park_name,
	   (homegames.attendance/games) AS avg_attendance,
	   year
FROM homegames INNER JOIN parks
		ON homegames.park=parks.park
WHERE year='2016'
	  AND games>10
ORDER BY homegames.attendance DESC
LIMIT 5;
*/

--Alternate method, includes team name (figure this join out!)
/*SELECT DISTINCT p.park_name, h.team,
	(h.attendance/h.games) as avg_attendance, t.name		
FROM homegames as h JOIN parks as p ON h.park = p.park
LEFT JOIN teams as t on h.team = t.teamid AND t.yearid = h.year
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;
*/

-- Question 9

/*Which managers have won the TSN Manager of the Year award in both 
the National League (NL) and the American League (AL)?
Give their full name and the teams that they were managing when 
they won the award.
*/

/*WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year;
*/



-- BONUS STUFF STARTS HERE



-- Question 10

/*Analyze all the colleges in the state of Tennessee. Which 
college has had the most success in the major leagues. Use whatever
metric for success you like - number of players, number of games, 
salaries, world series wins, etc.
*/

-- Question 11

/*Is there any correlation between number of wins and team salary? Use 
data from 2000 and later to answer this question. As you do this 
analysis, keep in mind that salaries across the whole league tend to
increase together, so you may want to look on a year-by-year basis.
*/

-- Question 12

/*In this question, you will explore the connection between number of wins
and attendance.Does there appear to be any correlation between attendance
at home games and number of wins? Do teams that win the world series see
a boost in attendance the following year? What about teams that made
the playoffs? Making the playoffs means either being a division winner
or a wild card winner.
*/

-- Question 13

/*It is thought that since left-handed pitchers are more rare, causing
batters to face them less often, that they are more effective. 
Investigate this claim and present evidence to either support or dispute
this claim. First, determine just how rare left-handed pitchers are
compared with right-handed pitchers. Are left-handed pitchers more likely
to win the Cy Young Award? Are they more likely to make it into the hall
of fame?
*/