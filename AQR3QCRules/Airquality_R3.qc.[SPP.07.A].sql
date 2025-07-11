USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP.07.A]    Script Date: 11/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[SPP.07.A] AS

-- Creation date: July 2025
-- QC rule code: SPP.07.A
-- QC rule name: SPP.07.A Vocabulary - [MeasurementType]

WITH CTE_samplingprocess AS ( 
SELECT --record_id, -- commented in SQL Server, necessary in Reportnet 3
CASE WHEN "measurementtype" = '' THEN NULL ELSE "measurementtype" END as "measurementtype" 
FROM reporting.SamplingProcess ) 

,missing_codes AS ( 
SELECT /*sp.record_id,*/ sp."measurementtype" -- commented in SQL Server, necessary in Reportnet 3
FROM CTE_samplingprocess sp 
--LEFT JOIN dataset_88666."vocabulary" v -- commented in SQL Server, necessary in Reportnet 3
LEFT JOIN reference.Vocabulary v -- added in SQL Server, it is replaced by the line from above in Reportnet 3
ON sp."measurementtype" = v."notation" --COLLATE Latin1_General_CI_AS 
AND v."vocabulary" = 'measurementtype' -- COLLATE added in SQL Server view 
WHERE v."notation" IS NULL ) 

SELECT /*record_id,*/ "measurementtype" FROM missing_codes -- commented in SQL Server, necessary in Reportnet 3

GO


