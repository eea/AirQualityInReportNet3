USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_06_A]    Script Date: 24/06/2026 13:55:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_01_A] AS

-- Creation date: June 2026


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
  (v."notation" IS NULL AND cc.countryCode IS NOT NULL) 
  
)

SELECT DISTINCT * FROM missing_codes





GO


