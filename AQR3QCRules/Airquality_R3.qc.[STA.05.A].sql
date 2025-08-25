USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.05.A]    Script Date: 25/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[STA.05.A] AS

-- Creation date: 25 August 2025
-- QC rule code: STA.05.A
-- QC rule name: STA.05.A Vocabulary - [AirQualityNetworkOrganisationalLevel]


WITH CTE_station AS ( 
SELECT --record_id ,
CASE WHEN "airqualitynetworkorganisationallevel" = '' THEN NULL ELSE "airqualitynetworkorganisationallevel" END as "airqualitynetworkorganisationallevel" 
FROM reporting.Station ) 

, missing_codes AS ( 
SELECT /*s.record_id,*/ s."airqualitynetworkorganisationallevel" 
FROM CTE_station s 
LEFT JOIN reference.Vocabulary v 
ON s."airqualitynetworkorganisationallevel" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'organisationallevel'
WHERE v."notation" IS NULL 
      AND s.airqualitynetworkorganisationallevel IS NOT NULL
) 

SELECT /*record_id,*/ "airqualitynetworkorganisationallevel" FROM missing_codes


GO

