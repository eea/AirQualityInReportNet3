USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_03_B_TEST]    Script Date: 10/06/2026 12:51:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [qc].[SPO_03_B] AS

-- Creation date: June 2026
-- QC rule code: SPO.03.B
-- QC rule name: SPO.03.B Constraint - [AirPollutantCode] SPO.02

WITH 
CTE_samplingPoint AS (
  SELECT 
    /*record_id
    ,*/CASE WHEN "assessmentmethodid" = '' THEN NULL 
      ELSE "assessmentmethodid" END as "assessmentmethodid"
    ,CASE WHEN "PollutantId" = '' THEN NULL 
	  --WHEN ISNUMERIC("airpollutantcode") THEN CAST(CAST("airpollutantcode" AS NUMERIC(32,16)) AS INTEGER) -- Reportnet 3
      WHEN ISNUMERIC("PollutantId") = 1 THEN CAST(CAST("PollutantId" AS NUMERIC(32,16)) AS INTEGER) -- SQL Server view
      ELSE NULL END as "PollutantId"
    FROM reporting."samplingpoint"
)

, several_AirPollutantCodes AS ( 
  SELECT DISTINCT 
         sp."assessmentmethodid",
         --COUNT(DISTINCT(sp."airpollutantcode")) -- Reportnet 3
		 COUNT(DISTINCT(sp."PollutantId")) AS CountingAirPollutantCode -- SQL Server view
  FROM CTE_samplingPoint sp 
  GROUP BY sp."assessmentmethodid"
  HAVING COUNT(DISTINCT(sp."PollutantId")) > 1
) 

SELECT -- record_id -- Reportnet 3
       DISTINCT sp."assessmentmethodid" -- SQL Server view
FROM CTE_samplingPoint sp 
INNER JOIN several_AirPollutantCodes sapc
ON sp."assessmentmethodid" = sapc."assessmentmethodid"

GO


