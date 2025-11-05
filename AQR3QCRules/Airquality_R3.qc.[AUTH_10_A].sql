USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUTH_10_A]  Script Date: 27/08/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[AUTH_10_A] AS

-- Creation date: 27 August 2025
-- QC rule code: AUTH_10_A
-- QC rule name: AUTH_10_A Vocabulary - [AuthorityStatus]

WITH CTE_authority AS ( 
SELECT /* record_id */ 
CASE WHEN "authoritystatus" = '' THEN NULL ELSE "authoritystatus" END as "authoritystatus" 
FROM reporting.Authority ) 

,missing_codes AS ( 
SELECT /*a.record_id,*/ a."authoritystatus" 
FROM CTE_authority a 
LEFT JOIN reference.Vocabulary v
ON a."authoritystatus" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'authoritystatus'
WHERE v."notation" IS NULL 
      AND a.authoritystatus IS NOT NULL
) 


SELECT * /*record_id,*/ FROM missing_codes

GO
