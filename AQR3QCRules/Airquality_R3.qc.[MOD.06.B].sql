USE [Airquality_R3]
GO

/****** Object:  View [qc].[MOD.06.B]    Script Date: 11/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[MOD.06.B] AS

-- Creation date: July 2025
-- QC rule code: MOD.06.B
-- QC rule name: MOD.06.B Constraint - [AirPollutantCode] MOD.02

WITH 
CTE_model AS ( 
  SELECT --record_id, -- commented in SQL Server, necessary in Reportnet 3
    CASE WHEN "assessmentmethodid" = '' THEN NULL 
    ELSE "assessmentmethodid" END as "assessmentmethodid" 
  , CASE WHEN "airpollutantcode" = '' THEN NULL 
     --WHEN ISNUMERIC("airpollutantcode") THEN CAST(CAST("airpollutantcode" AS NUMERIC(32,16)) AS INTEGER) ELSE NULL END as "airpollutantcode" -- commented in SQL Server, necessary in Reportnet 3
	 WHEN ISNUMERIC("airpollutantcode") = 1 THEN CAST(CAST("airpollutantcode" AS NUMERIC(32,16)) AS INTEGER) ELSE NULL END as "airpollutantcode" -- added in SQL Server, it is replaced by the line from above in Reportnet 3
  FROM reporting.Model) 

, several_AirPollutantCodes AS ( 
-- SELECT DISTINCT m."assessmentmethodid", COUNT(DISTINCT(m."airpollutantcode")) -- commented in SQL Server, necessary in Reportnet
SELECT DISTINCT m."assessmentmethodid", COUNT(DISTINCT(m."airpollutantcode")) AS CountingDifferentAirPollutantCodes -- added in SQL Server, it is replaced by the line from above in Reportnet 3
FROM CTE_model m 
GROUP BY m."assessmentmethodid"
HAVING COUNT(DISTINCT(m."airpollutantcode")) > 1
) 

SELECT --record_id, -- commented in SQL Server, necessary in Reportnet 3
  m.assessmentmethodid, m.airpollutantcode, sapc.CountingDifferentAirPollutantCodes -- added in SQL Server, it is replaced by record_id in Reportnet 3
FROM CTE_model m 
INNER JOIN several_AirPollutantCodes sapc
ON m."assessmentmethodid" = sapc."assessmentmethodid"


GO


