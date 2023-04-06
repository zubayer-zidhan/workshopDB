
-- TABLE CODE
CREATE TABLE dbo.Products 
   (
   ProductID INT IDENTITY(1,1),
   ProductName VARCHAR(100)
   )
GO
 
INSERT INTO Products (ProductName) VALUES ('Sir Rodney''s Marmalade') 
INSERT INTO Products (ProductName) VALUES ('Sir Rodney''s Scones') 
INSERT INTO Products (ProductName) VALUES ('Jack''s New England Clam Chowder') 
INSERT INTO Products (ProductName) VALUES ('Louisiana Fiery Hot Pepper Sauce')
INSERT INTO Products (ProductName) VALUES ('Louisiana Hot Spiced Okra ')

CREATE TABLE [dbo].[Synonyms] ( 
    [synonym] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL , 
    [word] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL  
) ON [PRIMARY] 
GO 
 
CREATE UNIQUE INDEX [IX_word] ON [dbo].[Synonyms]([word]) ON [PRIMARY] 
GO 
 
INSERT INTO synonyms VALUES ('Jam','Marmalade') 
INSERT INTO synonyms VALUES ('Chowda','Chowder') 
INSERT INTO synonyms VALUES ('Wicked Hot','Hot') 
INSERT INTO synonyms VALUES ('King','Sir')


-- CURSOR CODE

SET NOCOUNT ON 
 
DECLARE @word VARCHAR(50),  
    @position INT,  
    @newProductName VARCHAR(500),  
    @oldProductName VARCHAR(500),  
    @newWord VARCHAR(50), 
    @ProductName VARCHAR(500),
    @ProductID INT 
 
DECLARE load_cursor CURSOR FOR 
    SELECT ProductID, ProductName 
    FROM dbo.Products 
 
OPEN load_cursor 
FETCH NEXT FROM load_cursor INTO @ProductID, @ProductName 
 
WHILE @@FETCH_STATUS = 0 
BEGIN 
    SET @oldProductName = @ProductName 
    SET @ProductName = LTRIM(RTRIM(@ProductName)) 
    SET @newProductName = @ProductName 
    SET @position = CHARINDEX(' ', @ProductName, 1) 
 
    BEGIN 
         WHILE @position > 0 
         BEGIN 
              SET @word = LTRIM(RTRIM(LEFT(@ProductName, @position - 1))) 
              IF @word <> '' 
              BEGIN 
                SELECT @newWord = NULL 
                SELECT @newWord = synonym FROM Synonyms WHERE word = @word  
                IF @newWord IS NOT NULL 
                BEGIN 
                     SET @newProductName = REPLACE(@newProductName, @word, @newWord) 
                END 
              END 
              SET @ProductName = RIGHT(@ProductName, LEN(@ProductName) - @position) 
              SET @position = CHARINDEX(' ', @ProductName, 1) 
         END 
 
         SET @word = @ProductName 
         SELECT @newWord = NULL 
         SELECT @newWord = synonym FROM Synonyms WHERE word = @word 
         IF @newWord IS NOT NULL 
              SET @newProductName = REPLACE(@newProductName, @ProductName, @newWord) 
    END 
 
    IF @oldProductName <> @newProductName 
    BEGIN 
         SELECT @oldProductName AS OldProductName, @newProductName AS NewProductName
         --UPDATE dbo.Products SET ProductName = @newProductName WHERE ProductID = @ProductID  
    END 
 
    FETCH NEXT FROM load_cursor INTO @ProductID, @ProductName 
END 
 
CLOSE load_cursor 
DEALLOCATE load_cursor 
GO