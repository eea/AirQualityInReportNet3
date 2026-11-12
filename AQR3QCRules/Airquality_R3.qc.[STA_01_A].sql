USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_01_A]    Script Date: 09/11/2026 16:46:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_01_A] AS

-- Creation date: June 2026
-- QC rule code: STA_01_A
-- QC rule name: STA_01_A Content check - [CountryCode]
-- QC rule description: CountryCode must be reported as a valid ISO2 country code corresponding to the reporting country.

WITH CTE_countryCode AS ( 
SELECT --record_id ,
NULLIF(LTRIM(RTRIM(countryCode)), '') AS countryCode
FROM reporting.MeasurementStation ) ,

missing_codes AS ( 
SELECT /*sp.record_id,*/ cc.countryCode 
FROM CTE_countryCode cc 
LEFT JOIN reference."vocabulary" v 
ON cc.countryCode = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'countries'
WHERE 
  v."notation" IS NULL
  -- OR cc.countryCode <> '{%R3_COUNTRY_CODE%}'   
)

SELECT DISTINCT * FROM missing_codes
GO