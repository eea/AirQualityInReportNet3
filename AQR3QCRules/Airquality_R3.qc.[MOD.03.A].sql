USE [Airquality_R3]
GO

/****** Object:  View [qc].[MOD.03.A]    Script Date: 01/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [qc].[MOD.03.A] AS

-- Creation date: June 2025

WITH CTE_model AS ( 
    SELECT 
        CASE WHEN dataaggregationprocessid = '' THEN NULL 
            ELSE dataaggregationprocessid 
        END AS dataaggregationprocessid
    FROM reporting.Model
), 
missing_codes AS ( 
    SELECT 
       *
    FROM CTE_model m 
    LEFT JOIN reference.Vocabulary v 
        ON m.dataaggregationprocessid = v.notation 
        AND v.vocabulary = 'aggregationprocess'
    WHERE v.notation IS NULL
	      AND m.dataaggregationprocessid IS NOT NULL
)

SELECT * FROM missing_codes;
GO


