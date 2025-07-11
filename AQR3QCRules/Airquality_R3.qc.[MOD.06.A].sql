USE [Airquality_R3]
GO

/****** Object:  View [qc].[MOD.06.A]    Script Date: 11/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[MOD.06.A] AS

-- Creation date: July 2025
-- QC rule code: MOD.06.A
-- QC rule name: MOD.06.A Vocabulary - [AirPollutantCode]

WITH CTE_model AS (
  SELECT 
    --record_id,
    CASE WHEN "airpollutantcode" = '' THEN NULL ELSE "airpollutantcode" END as "airpollutantcode" 
  FROM reporting."model" 
) 

,missing_codes AS (
  SELECT 
    --m.record_id,
    m."airpollutantcode" 
  FROM CTE_model m 
    LEFT JOIN reference."vocabulary" v 
      ON m."airpollutantcode" = v."notation" 
      AND v."vocabulary" = 'pollutant' 
  WHERE v."notation" IS NULL 
) 

SELECT * FROM missing_codes

GO


