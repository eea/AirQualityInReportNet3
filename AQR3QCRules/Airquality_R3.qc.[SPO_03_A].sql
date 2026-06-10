USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_03_A]    Script Date: 10/06/2026 11:57:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[SPO_03_A] AS

-- Creation date: June 2026
-- QC rule code: SPO.03.A
-- QC rule name: SPO.03.A Vocabulary - [AirPollutantCode]

WITH CTE_samplingpoint AS ( 
SELECT --record_id ,
NULLIF(LTRIM(RTRIM([PollutantId])), '') AS [PollutantId]
FROM reporting."samplingpoint" ) ,

vocab AS (
SELECT
v.[ID],
RIGHT(v.[ID], CHARINDEX('/', REVERSE(v.[ID])) - 1) AS [PollutantSuffix]
FROM [reference].[vocabulary] v
WHERE v.[vocabulary] = 'pollutant'
),


missing_codes AS ( 
SELECT /*sp.record_id,*/ sp."PollutantId" 
FROM CTE_samplingpoint sp 
LEFT JOIN vocab v
ON v.[PollutantSuffix] = sp.[PollutantId]
WHERE v.[ID] IS NULL)

SELECT DISTINCT * FROM missing_codes

GO


