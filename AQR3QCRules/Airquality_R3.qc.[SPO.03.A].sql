USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO.03.A]    Script Date: 17/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[SPO.03.A] AS

-- Creation date: July 2025
-- QC rule code: SPO.03.A
-- QC rule name: SPO.03.A Vocabulary - [AirPollutantCode]

WITH CTE_samplingpoint AS ( 
SELECT --record_id ,
CASE WHEN "airpollutantcode" = '' THEN NULL ELSE "airpollutantcode" END as "airpollutantcode" 
FROM reporting."samplingpoint" ) 

,missing_codes AS ( 
SELECT /*sp.record_id,*/ sp."airpollutantcode" 
FROM CTE_samplingpoint sp 
LEFT JOIN reference."vocabulary" v 
ON sp."airpollutantcode" = v."notation" AND v."vocabulary" = 'pollutant'
WHERE v."notation" IS NULL ) 

SELECT DISTINCT * FROM missing_codes

GO


