IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ProjectDB')
BEGIN
    CREATE DATABASE ProjectDB;
END;
GO

USE ProjectDB;
GO

CREATE TABLE Call_center_Data (
    call_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    agent NVARCHAR(50),
    [DATE] DATE,
    [TIME] TIME,
    Topic NVARCHAR(100),
    Answered NVARCHAR(10),
    Resolved NVARCHAR(10),
    Speed_of_answer_in_seconds INT,
    Avg_Talk_Duration TIME,
    Satisfaction_rating INT
);
GO


