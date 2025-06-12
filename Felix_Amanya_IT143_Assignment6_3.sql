-- Drop the table if it exists
IF OBJECT_ID('HelloWorld', 'U') IS NOT NULL
    DROP TABLE HelloWorld;
GO

-- Create the HelloWorld table
CREATE TABLE HelloWorld
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(100),
    LastModifiedDate DATETIME NULL,
    LastModifiedBy NVARCHAR(100) NULL
);
GO

-- Insert sample data
INSERT INTO HelloWorld (FirstName, LastName, Email)
VALUES
('Felix', 'Amanya', 'felix@example.com'),
('John', 'Doe', 'john@example.com'),
('Jane', 'Smith', 'jane@example.com');
GO

-- Drop the function if it exists
IF OBJECT_ID('dbo.fn_CheckDuplicateName', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CheckDuplicateName;
GO

-- Create the function to check for duplicate names
CREATE FUNCTION dbo.fn_CheckDuplicateName
(
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    SELECT @Result = 
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM HelloWorld
                WHERE FirstName = @FirstName AND LastName = @LastName
            )
            THEN 1
            ELSE 0
        END;

    RETURN @Result;
END;
GO

-- Test the duplicate check function
SELECT dbo.fn_CheckDuplicateName('Felix', 'Amanya') AS IsDuplicate;
GO

-- Drop the function if it exists
IF OBJECT_ID('dbo.fn_GetFirstName', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetFirstName;
GO

-- Create function to extract first name from full name
CREATE FUNCTION dbo.fn_GetFirstName (@FullName NVARCHAR(200))
RETURNS NVARCHAR(100)
AS
BEGIN
    RETURN LEFT(@FullName, CHARINDEX(' ', @FullName + ' ') - 1)
END;
GO

-- Drop the function if it exists
IF OBJECT_ID('dbo.fn_GetLastName', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetLastName;
GO

-- Create function to extract last name from full name
CREATE FUNCTION dbo.fn_GetLastName (@FullName NVARCHAR(200))
RETURNS NVARCHAR(100)
AS
BEGIN
    RETURN LTRIM(RIGHT(@FullName, LEN(@FullName) - CHARINDEX(' ', @FullName + ' ')))
END;
GO

-- Test first and last name functions
SELECT dbo.fn_GetFirstName('Felix Amanya') AS FirstName,
       dbo.fn_GetLastName('Felix Amanya') AS LastName;
GO

-- Drop the trigger if it exists
IF OBJECT_ID('trg_UpdateHelloWorldAudit', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateHelloWorldAudit;
GO

-- Create trigger to update audit fields
CREATE TRIGGER trg_UpdateHelloWorldAudit
ON HelloWorld
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE H
    SET 
        LastModifiedDate = GETDATE(),
        LastModifiedBy = SYSTEM_USER
    FROM HelloWorld H
    INNER JOIN inserted I ON H.ID = I.ID;
END;
GO

-- Test the trigger
UPDATE HelloWorld
SET FirstName = 'Test'
WHERE ID = 1;
GO

-- View the updated row
SELECT * FROM HelloWorld WHERE ID = 1;
GO
