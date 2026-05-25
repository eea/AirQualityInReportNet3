USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.05.A]    Script Date: 25/05/2026 13:53:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_05_A] AS

-- Creation date: 25 August 2025
-- QC rule code: STA.05.A
-- QC rule name: STA.05.A Vocabulary - [AirQualityNetworkOrganisationalLevel]


WITH CTE_station AS ( 
SELECT --record_id ,
CASE WHEN "NetworkOrganisationalLevel" = '' THEN NULL ELSE "NetworkOrganisationalLevel" END as "NetworkOrganisationalLevel" 
FROM reporting.MeasurementStation ) 

, missing_codes AS ( 
SELECT /*s.record_id,*/ s."NetworkOrganisationalLevel" 
FROM CTE_station s 
LEFT JOIN reference.Vocabulary v 
ON s."NetworkOrganisationalLevel" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'organisationallevel'
WHERE v."notation" IS NULL 
      AND s."NetworkOrganisationalLevel" IS NOT NULL
) 

SELECT /*record_id,*/ "NetworkOrganisationalLevel" FROM missing_codes


GO


