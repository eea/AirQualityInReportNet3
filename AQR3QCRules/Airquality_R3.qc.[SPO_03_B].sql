USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_03_B]    Script Date: 17/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPO_03_B] AS

-- Creation date: July 2025
-- QC rule code: SPO_03_B
-- QC rule name: SPO_03_B Constraint - [AirPollutantCode] SPO_02

WITH 
CTE_samplingPoint AS (
  SELECT 
    /*record_id
    ,*/CASE WHEN "assessmentmethodid" = '' THEN NULL 
      ELSE "assessmentmethodid" END as "assessmentmethodid"
    ,CASE WHEN "airpollutantcode" = '' THEN NULL 
	  --WHEN ISNUMERIC("airpollutantcode") THEN CAST(CAST("airpollutantcode" AS NUMERIC(32,16)) AS INTEGER) -- Reportnet 3
      WHEN ISNUMERIC("airpollutantcode") = 1 THEN CAST(CAST("airpollutantcode" AS NUMERIC(32,16)) AS INTEGER) -- SQL Server view
      ELSE NULL END as "airpollutantcode"
    FROM reporting."samplingpoint"
)

, several_AirPollutantCodes AS ( 
  SELECT DISTINCT 
         sp."assessmentmethodid",
         --COUNT(DISTINCT(sp."airpollutantcode")) -- Reportnet 3
		 COUNT(DISTINCT(sp."airpollutantcode")) AS CountingAirPollutantCode -- SQL Server view
  FROM CTE_samplingPoint sp 
  GROUP BY sp."assessmentmethodid"
  HAVING COUNT(DISTINCT(sp."airpollutantcode")) > 1
) 

SELECT -- record_id -- Reportnet 3
       DISTINCT sp."assessmentmethodid" -- SQL Server view
FROM CTE_samplingPoint sp 
INNER JOIN several_AirPollutantCodes sapc
ON sp."assessmentmethodid" = sapc."assessmentmethodid"

GO


