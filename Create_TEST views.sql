-- Script: Create *_TEST views in schema qctesting based on existing views in schema qc
-- Database: Airquality_R3
-- Behavior:
--  - For each source view [qc].[<name>] listed below, create [qctesting].[<name>_TEST]
--  - In the view body replace references to the "reporting" and "reference" schemas with "qctesting"
--  - Skip creation if the target view already exists in schema qctesting
--  - Uses dynamic SQL (sp_executesql) so CREATE VIEW runs in its own batch
--  - Basic error handling per view with BEGIN TRY / BEGIN CATCH


USE [Airquality_R3];
GO

SET NOCOUNT ON;

DECLARE @ViewList TABLE (src_name SYSNAME);
INSERT INTO @ViewList (src_name) VALUES
 ('STA_09_A'),
 ('STA_08_B'),
 ('STA_04_B'),
 ('ZOG_PK'),
 ('ZOG_0'),
 ('ZOG_01_A'),
 ('ZOG_02_A'),
 ('ZOG_02_B');

DECLARE
  @srcName SYSNAME,
  @newName SYSNAME,
  @definition NVARCHAR(MAX),
  @upperDef NVARCHAR(MAX),
  @posHeader INT,
  @posAS INT,
  @body NVARCHAR(MAX),
  @bodyReplaced NVARCHAR(MAX),
  @createSql NVARCHAR(MAX);

DECLARE view_cursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT src_name FROM @ViewList;

OPEN view_cursor;
FETCH NEXT FROM view_cursor INTO @srcName;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @newName = @srcName + '_TEST';

  -- Get view definition from schema 'qc'
  SELECT @definition = sm.definition
  FROM sys.views v
  JOIN sys.schemas s ON v.schema_id = s.schema_id
  JOIN sys.sql_modules sm ON v.object_id = sm.object_id
  WHERE v.name = @srcName
    AND s.name = 'qc';

  IF @definition IS NULL
  BEGIN
    PRINT 'Warning: Source view [' + 'qc' + '].[' + @srcName + '] not found or definition not accessible (possibly encrypted). Skipping.';
    FETCH NEXT FROM view_cursor INTO @srcName;
    CONTINUE;
  END

  -- Find the AS that separates the header from the body.
  SET @upperDef = UPPER(@definition);
  SET @posHeader = CHARINDEX('CREATE VIEW', @upperDef);
  IF @posHeader = 0
    SET @posHeader = CHARINDEX('ALTER VIEW', @upperDef);

  IF @posHeader = 0
  BEGIN
    PRINT 'Warning: Could not find CREATE/ALTER VIEW in definition for [' + @srcName + ']. Skipping.';
    FETCH NEXT FROM view_cursor INTO @srcName;
    CONTINUE;
  END

  SET @posAS = CHARINDEX('AS', @upperDef, @posHeader);
  IF @posAS = 0
  BEGIN
    PRINT 'Warning: Could not find AS in definition for [' + @srcName + ']. Skipping.';
    FETCH NEXT FROM view_cursor INTO @srcName;
    CONTINUE;
  END

  -- Extract everything after the first AS (this is the view body)
  SET @body = SUBSTRING(@definition, @posAS + 2, DATALENGTH(@definition));
  -- Perform schema replacements: reporting -> qctesting, reference -> qctesting
  -- Handle bracketed and unbracketed forms.
  SET @bodyReplaced = @body;
  SET @bodyReplaced = REPLACE(@bodyReplaced, '[reporting]', '[qctesting]');
  SET @bodyReplaced = REPLACE(@bodyReplaced, '[reference]', '[qctesting]');
  SET @bodyReplaced = REPLACE(@bodyReplaced, 'reporting.', 'qctesting.');
  SET @bodyReplaced = REPLACE(@bodyReplaced, 'reference.', 'qctesting.');

  -- Build CREATE VIEW statement for target
  SET @createSql =
    N'CREATE VIEW ' + QUOTENAME('qctesting') + N'.' + QUOTENAME(@newName) + N' AS' + @bodyReplaced;

  -- Check existence in qctesting schema and conditionally create
  IF NOT EXISTS (
      SELECT 1
      FROM sys.views v
      JOIN sys.schemas s ON v.schema_id = s.schema_id
      WHERE v.name = @newName
        AND s.name = 'qctesting'
    )
  BEGIN
    BEGIN TRY
      EXEC sp_executesql @createSql;
      PRINT 'Created view: ' + QUOTENAME('qctesting') + '.' + QUOTENAME(@newName);
    END TRY
    BEGIN CATCH
      PRINT 'Error creating view ' + @newName + ': ' + ERROR_MESSAGE();
    END CATCH;
  END
  ELSE
  BEGIN
    PRINT 'Skipped (already exists): ' + QUOTENAME('qctesting') + '.' + QUOTENAME(@newName);
  END

  FETCH NEXT FROM view_cursor INTO @srcName;
END

CLOSE view_cursor;
DEALLOCATE view_cursor;

GO