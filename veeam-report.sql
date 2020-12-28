USE	VeeamBackup;

WITH cte AS
(
SELECT	js.id, js.job_id,
		job_name, 
		creation_time,
		CASE	WHEN @@SERVERNAME LIKE '%SCPBKSP01%' THEN 'Supreme Court'
				WHEN @@SERVERNAME LIKE '%ADPBKSP01%' THEN 'The Adelphi'
		END as [site],
		[dbo].[System.FormatDateTimeDiff](creation_time, end_time) AS duration,
		processed_objects AS [objects],
		dbo.[System.FormatSize](stored_size) AS [size],
		CASE result WHEN 0 THEN 'Success'
					WHEN 1 THEN ' Warning'
					WHEN 2 THEN 'Error'
		END AS result,
		ROW_NUMBER() OVER (PARTITION BY js.job_id ORDER BY creation_time) AS jobs,
		MAX(creation_time) OVER (PARTITION BY js.job_id) AS last_creation_time
FROM	[Backup.Model.JobSessions] js
JOIN	[Backup.Model.BackupJobSessions] bjs ON js.id = bjs.id
WHERE	job_type IN (0,12003, 24, 28) AND end_time >= DATEADD(DAY,-1,GETDATE())
)

SELECT	job_name AS [Job Name], [site] AS [Site], duration AS [Duration], size AS [Size], jobs as [Jobs Ran], result as [Last Result]
FROM	cte
WHERE	creation_time  = last_creation_time
ORDER BY job_name


