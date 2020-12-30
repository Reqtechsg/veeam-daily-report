USE	VeeamBackup;

USE	VeeamBackup;

WITH cte AS
(
SELECT	js.id, 
		js.job_id,
		job_name, 
		creation_time,
		SERVERPROPERTY('MachineName') AS [server],
		[dbo].[System.FormatDateTimeDiff](creation_time, end_time) AS duration,
		SUM(DATEDIFF(SECOND, creation_time, end_time)) OVER (PARTITION BY js.job_id) AS total_duration_in_seconds,
		processed_objects AS [objects],
		dbo.[System.FormatSize](stored_size) AS [size],
		CASE result WHEN 0 THEN 'Success'
					WHEN 1 THEN ' Warning'
					WHEN 2 THEN 'Error'
		END AS result,
		ROW_NUMBER() OVER (PARTITION BY js.job_id ORDER BY creation_time) AS attempt,
		MAX(creation_time) OVER (PARTITION BY js.job_id) AS last_creation_time
FROM	[Backup.Model.JobSessions] js
JOIN	[Backup.Model.BackupJobSessions] bjs ON js.id = bjs.id
WHERE	job_type IN (0,12003, 24, 28) AND end_time >= DATEADD(DAY,-1,GETDATE())
)

SELECT		[server] AS [Veeam Server],
			job_name AS [Job Name],  
			size AS [Size], 
			attempt as [Attempts], 
			RIGHT('0' + CAST(total_duration_in_seconds / 3600 AS VARCHAR), 2) + ':' +
			RIGHT('0' + CAST((total_duration_in_seconds / 60) % 60 AS VARCHAR), 2) + ':' +
			RIGHT('0' + CAST(total_duration_in_seconds % 60 AS VARCHAR), 2) AS [Total Duration], 
			result as [Result]
FROM		cte
WHERE		creation_time  = last_creation_time
ORDER BY	job_name

