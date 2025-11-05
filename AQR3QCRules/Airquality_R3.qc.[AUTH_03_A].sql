USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUTH_03_A]  Script Date: 26/08/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[AUTH_03_A] AS

-- Creation date: 26 August 2025
-- QC rule code: AUTH_03_A
-- QC rule name: AUTH_03_A Vocabulary - [Object]



WITH CTE_authority AS ( 
SELECT -- record_id ,
CASE WHEN "object" = '' THEN NULL ELSE "object" END as "object" 
FROM reporting.Authority ) 

,missing_codes AS ( 
SELECT /* a.record_id, */
          a."object" 
FROM CTE_authority a 
LEFT JOIN reference.Vocabulary v 
ON a."object" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'authorityobject'
WHERE v."notation" COLLATE Latin1_General_CI_AS IS NULL 
      AND a.object IS NOT NULL
) 

SELECT /*record_id,*/ "object" FROM missing_codes

GO