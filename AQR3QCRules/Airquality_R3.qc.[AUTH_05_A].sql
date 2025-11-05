USE [Airquality_R3];
GO

/****** Object:  View [qc].[AUTH_05_A]  Script Date: 27/08/2025 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [qc].[AUTH_05_A] AS

-- Creation date: 27 August 2025
-- QC rule code: AUTH_05_A
-- QC rule name: AUTH_05_A Vocabulary - [AuthorityInstance]

WITH CTE_authority AS ( 
    SELECT 
        --record_id,
        CASE 
            WHEN authorityinstance = '' THEN NULL 
            ELSE authorityinstance 
        END AS authorityinstance
    FROM reporting.Authority
) 
, missing_codes AS ( 
    SELECT 
        --a.record_id,
        a.authorityinstance
    FROM CTE_authority a
    LEFT JOIN reference.Vocabulary v
        ON a.authorityinstance = v.notation COLLATE Latin1_General_CI_AS
       AND v.vocabulary = 'authorityinstance'
    WHERE v.notation COLLATE Latin1_General_CI_AS IS NULL 
      AND a.authorityinstance IS NOT NULL
) 

SELECT 
    --record_id,
    authorityinstance
FROM missing_codes;
GO

