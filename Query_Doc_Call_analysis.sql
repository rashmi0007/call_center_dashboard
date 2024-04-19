SELECT * FROM [dbo].[Call_center_Data];
----------------------
SELECT COUNT(*) AS total_calls FROM [dbo].[Call_center_Data];
----------------------
SELECT COUNT(*) AS calls_answered FROM [dbo].[Call_center_Data] d WHERE d.Answered=1;
----------------------
SELECT Agent FROM [dbo].[Call_center_Data] GROUP BY Agent;
----------------------
WITH 
resolve_cte AS(
SELECT COUNT(*) AS resolved FROM [dbo].[Call_center_Data] WHERE Resolved=1),
unresolved_cte AS(
SELECT COUNT(*) AS unresolved FROM [dbo].[Call_center_Data] WHERE Resolved=0),
final_cte AS(
SELECT 
CAST(resolved AS varchar(40)) AS resolved,
CAST(CAST((resolved*1.0/(unresolved+resolved))*100 AS decimal(10,2))AS varchar(24)) AS resolved_perc,
CAST(unresolved AS varchar(40)) AS unresolved,
CAST(CAST((unresolved*1.0/(unresolved+resolved))*100 AS decimal(10,2))AS varchar(24)) AS unresolved_perc
FROM resolve_cte re, unresolved_cte ure)
SELECT 
CONCAT(resolved,' Calls',' -> ',resolved_perc,'%') AS Resolved_status,
CONCAT(unresolved,' Calls',' -> ',unresolved_perc,'%') AS Unresolved_status
FROM final_cte;
-------------------------
WITH 
resolve_cte AS(
SELECT COUNT(*) AS resolved,DATENAME(WEEKDAY,DATE) AS week_Day FROM [dbo].[Call_center_Data] WHERE Resolved=1 GROUP BY DATENAME(WEEKDAY,DATE)),
day_counts AS(
SELECT COUNT(*) AS total_calls,DATENAME(WEEKDAY,DATE) AS week_of_day FROM [dbo].[Call_center_Data]
GROUP BY DATENAME(WEEKDAY,DATE))
SELECT r.week_Day,c.total_calls,r.resolved FROM day_counts c INNER JOIN resolve_cte r
ON c.week_of_day=r.week_Day ORDER BY c.total_calls DESC
-------------------------
WITH total_calls AS (
SELECT Agent,COUNT(*) AS Total_Calls FROM [dbo].[Call_center_Data] GROUP BY Agent),
answered_calls AS (
SELECT Agent,COUNT(*) AS Answered FROM [dbo].[Call_center_Data] WHERE Answered =1 GROUP BY Agent),
resolved_calls AS (
SELECT Agent,COUNT(*) AS Resolved FROM [dbo].[Call_center_Data] WHERE Resolved =1 GROUP BY Agent)
SELECT
tc.Agent,tc.Total_calls,ac.Answered,rc.Resolved
FROM total_calls tc INNER JOIN answered_calls ac ON tc.Agent=ac.Agent INNER JOIN resolved_calls rc
ON tc.Agent=rc.Agent ORDER BY tc.Total_Calls DESC,ac.Answered DESC; 

--------------------------
WITH total_calls AS (
SELECT Topic,COUNT(*) AS Total_Calls FROM [dbo].[Call_center_Data] GROUP BY Topic),
resolved_calls AS (
SELECT Topic,COUNT(*) AS Resolved_call FROM [dbo].[Call_center_Data] WHERE Resolved =1 GROUP BY Topic),
unresolved_calls AS (
SELECT Topic,COUNT(*) AS Unresolved_call FROM [dbo].[Call_center_Data] WHERE Resolved =0 GROUP BY Topic)
SELECT
tc.Topic,tc.Total_calls,ac.Resolved_call,rc.Unresolved_call
FROM total_calls tc INNER JOIN resolved_calls ac ON tc.Topic=ac.Topic INNER JOIN unresolved_calls rc
ON tc.Topic=rc.Topic ORDER BY tc.Total_Calls DESC,ac.Resolved_call DESC; 

----------------------
SELECT COUNT(*) AS Unresolved_call FROM [dbo].[Call_center_Data] WHERE Resolved =0;

----------------------
SELECT a.Agent,
CAST(ROUND((b.sum_of_rating/a.no_of_call),2) AS decimal(10,2)) AS avg_rating
FROM
(SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id,Agent,COUNT(*) AS no_of_call FROM [dbo].[Call_center_Data] WHERE Answered=1 GROUP BY Agent) a
INNER JOIN
(SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id, Agent,SUM(Satisfaction_rating)*1.0 AS sum_of_rating FROM [dbo].[Call_center_Data] GROUP BY Agent) b
ON a.agent_id=b.agent_id
ORDER BY avg_rating DESC;

----------------------
WITH total_cte AS(
SELECT COUNT(call_id) AS Total_call FROM [dbo].[Call_center_Data]),
topic_perc AS(
SELECT Topic,CAST(ROUND(((COUNT(call_id)*1.0)/(SELECT Total_call FROM total_cte))*100,2) AS decimal(10,2)) AS 'Per_of_total'
FROM [dbo].[Call_center_Data] GROUP BY Topic)
SELECT * FROM topic_perc ORDER BY Per_of_total ASC;

---------------------
WITH
total_time_cte AS
(
SELECT 
DATEPART(HOUR,Avg_Talk_Duration)*60+
DATEPART(MINUTE,Avg_Talk_Duration)+
DATEPART(SECOND,Avg_Talk_Duration)/60.0 
AS minutes FROM [dbo].[Call_center_Data] 
WHERE Resolved=1),
resolved_call AS 
(SELECT COUNT(*) AS total_call 
FROM [dbo].[Call_center_Data] 
WHERE Resolved=1)
SELECT CAST(ROUND((SELECT SUM(minutes) FROM total_time_cte)
/(SELECT total_call FROM resolved_call),2)AS decimal(10,2)) AS average_resolve_time_per_call

----------------------
SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id, Agent,COUNT(call_id) AS Calls_answered FROM [dbo].[Call_center_Data] WHERE Answered=1 GROUP BY Agent;
SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id,Agent,COUNT(call_id) AS Calls_abandon FROM [dbo].[Call_center_Data] WHERE Answered=0 GROUP BY Agent;
SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id,Agent,COUNT(call_id) AS Resolved_calls FROM [dbo].[Call_center_Data] WHERE Resolved=1 GROUP BY Agent;
SELECT ROW_NUMBER() OVER(ORDER BY Agent ASC) AS agent_id,Agent,COUNT(call_id) AS Total_calls FROM [dbo].[Call_center_Data] GROUP BY Agent;
SELECT COUNT(call_id) AS total_call FROM [dbo].[Call_center_Data];


---------------------------
WITH total_time_cte AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Agent ASC) AS agent_id,
        Agent,
        SUM(DATEPART(HOUR, Avg_Talk_Duration) * 60 +
            DATEPART(MINUTE, Avg_Talk_Duration) +
            DATEPART(SECOND, Avg_Talk_Duration) / 60.0) AS total_minutes
    FROM [dbo].[Call_center_Data] 
    WHERE Resolved = 1 
    GROUP BY Agent
),
resolved_call AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY Agent ASC) AS agent_id,
        Agent,
        COUNT(*) AS total_call 
    FROM [dbo].[Call_center_Data] 
    WHERE Resolved = 1 
    GROUP BY Agent
)
SELECT 
    tc.Agent,
    CAST(ROUND((tc.total_minutes) / (rc.total_call), 2) AS decimal(10, 2)) AS average_resolve_time_per_call
FROM 
    total_time_cte tc
INNER JOIN
    resolved_call rc ON tc.agent_id = rc.agent_id;