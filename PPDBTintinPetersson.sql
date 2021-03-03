USE [master]
GO
/****** Object:  Database [PragueParking3]    Script Date: 2021-02-05 12:11:26 ******/
CREATE DATABASE [PragueParking3]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Prague Parking 3.0', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Prague Parking 3.0.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Prague Parking 3.0_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Prague Parking 3.0_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
USE [PragueParking3]
GO
/****** Object:  Table [dbo].[ParkingSpot]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingSpot](
	[SpotID] [int] IDENTITY(1,1) NOT NULL,
	[SpotNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SpotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParkedVehicle]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkedVehicle](
	[VehicleID] [int] IDENTITY(1,1) NOT NULL,
	[Regnum] [nvarchar](10) NOT NULL,
	[InTime] [datetime] NOT NULL,
	[SpotID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AllParkedVehicles]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AllParkedVehicles]
AS
SELECT pv.Regnum, ps.SpotNumber, DATEDIFF(HOUR, pv.InTime, GETDATE()) 
AS [Hours Parked], pv.TypeID 
FROM ParkedVehicle pv
JOIN ParkingSpot ps 
ON pv.SpotID = ps.SpotID
GO
/****** Object:  View [dbo].[Empty Spots]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Empty Spots]
AS
SELECT SpotNumber FROM ParkingSpot
WHERE SpotID NOT IN (SELECT SpotID FROM ParkedVehicle);
GO
/****** Object:  Table [dbo].[VehicleType]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleType](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](10) NOT NULL,
	[Size] [int] NOT NULL,
	[HourlyRate] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OptimizeMC]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OptimizeMC]
AS
SELECT pv.Regnum, ps.SpotNumber 
FROM ParkedVehicle pv
JOIN VehicleType vt 
ON pv.TypeID = vt.TypeID
JOIN ParkingSpot ps 
ON pv.SpotID = ps.SpotID

WHERE pv.SpotID IN 
(
SELECT pv.SpotID 
FROM ParkedVehicle pv
JOIN VehicleType vt ON pv.TypeID = vt.TypeID
GROUP BY pv.SpotID
HAVING SUM(vt.Size) = 1
);
GO
/****** Object:  View [dbo].[VehiclesParked]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VehiclesParked]
AS
SELECT pv.Regnum, ps.SpotNumber, DATEDIFF(HOUR, pv.InTime, GETDATE()) 
AS [Hours Parked], pv.TypeID 
FROM ParkedVehicle pv
JOIN ParkingSpot ps 
ON pv.SpotID = ps.SpotID
GO
/****** Object:  Table [dbo].[VehicleHistory]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleHistory](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[Regnum] [nvarchar](10) NOT NULL,
	[InTime] [datetime] NOT NULL,
	[OutTime] [datetime] NOT NULL,
	[Fee] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Income per day]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[Income per day]
AS
SELECT SUM(Fee) AS [Income], CONVERT(DATE, OutTime) 
AS [Date] 
FROM VehicleHistory
GROUP BY CONVERT(DATE, OutTime);
GO
SET IDENTITY_INSERT [dbo].[ParkedVehicle] ON 
GO
SET IDENTITY_INSERT [dbo].[ParkingSpot] ON 
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (1, 1)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (2, 2)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (3, 3)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (4, 4)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (5, 5)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (6, 6)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (7, 7)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (8, 8)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (9, 9)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (10, 10)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (11, 11)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (12, 12)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (13, 13)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (14, 14)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (15, 15)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (16, 16)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (17, 17)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (18, 18)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (19, 19)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (20, 20)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (21, 21)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (22, 22)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (23, 23)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (24, 24)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (25, 25)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (26, 26)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (27, 27)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (28, 28)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (29, 29)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (30, 30)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (31, 31)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (32, 32)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (33, 33)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (34, 34)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (35, 35)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (36, 36)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (37, 37)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (38, 38)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (39, 39)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (40, 40)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (41, 41)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (42, 42)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (43, 43)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (44, 44)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (45, 45)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (46, 46)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (47, 47)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (48, 48)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (49, 49)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (50, 50)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (51, 51)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (52, 52)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (53, 53)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (54, 54)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (55, 55)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (56, 56)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (57, 57)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (58, 58)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (59, 59)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (60, 60)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (61, 61)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (62, 62)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (63, 63)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (64, 64)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (65, 65)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (66, 66)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (67, 67)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (68, 68)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (69, 69)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (70, 70)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (71, 71)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (72, 72)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (73, 73)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (74, 74)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (75, 75)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (76, 76)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (77, 77)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (78, 78)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (79, 79)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (80, 80)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (81, 81)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (82, 82)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (83, 83)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (84, 84)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (85, 85)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (86, 86)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (87, 87)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (88, 88)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (89, 89)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (90, 90)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (91, 91)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (92, 92)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (93, 93)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (94, 94)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (95, 95)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (96, 96)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (97, 97)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (98, 98)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (99, 99)
GO
INSERT [dbo].[ParkingSpot] ([SpotID], [SpotNumber]) VALUES (100, 100)
GO
SET IDENTITY_INSERT [dbo].[ParkingSpot] OFF
GO
SET IDENTITY_INSERT [dbo].[VehicleType] ON 
GO
INSERT [dbo].[VehicleType] ([TypeID], [TypeName], [Size], [HourlyRate]) VALUES (1, N'Motorcycle', 1, 10.0000)
GO
INSERT [dbo].[VehicleType] ([TypeID], [TypeName], [Size], [HourlyRate]) VALUES (2, N'Car', 2, 20.0000)
GO
SET IDENTITY_INSERT [dbo].[VehicleType] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Unique_Regnum]    Script Date: 2021-02-05 12:11:26 ******/
ALTER TABLE [dbo].[ParkedVehicle] ADD  CONSTRAINT [Unique_Regnum] UNIQUE NONCLUSTERED 
(
	[Regnum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleHistory] ADD  DEFAULT ((0)) FOR [Fee]
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD FOREIGN KEY([SpotID])
REFERENCES [dbo].[ParkingSpot] ([SpotID])
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD FOREIGN KEY([TypeID])
REFERENCES [dbo].[VehicleType] ([TypeID])
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])>(2)))
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])<(11)))
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])>(2)))
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])<(11)))
GO
/****** Object:  StoredProcedure [dbo].[AddVehicle]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------

CREATE PROCEDURE [dbo].[AddVehicle]
@Regnum NVARCHAR(10), @TypeID INT
AS
DECLARE @ParkingSpot INT
EXECUTE FindEmptySpot @TypeID, @ParkingSpot OUTPUT

BEGIN TRANSACTION
BEGIN TRY
INSERT INTO ParkedVehicle(Regnum, InTime, SpotID, TypeID)
VALUES(@Regnum, GETDATE(), @ParkingSpot, @TypeID)
COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[FindEmptySpot]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FindEmptySpot]
@TypeID INT,
@EmptySpot INT OUTPUT
AS

IF @TypeID = 1
BEGIN
SET @EmptySpot = 
(
SELECT TOP 1 ps.SpotID 
FROM ParkingSpot ps
JOIN ParkedVehicle pv 
ON ps.SpotID = pv.SpotID
JOIN VehicleType vt 
ON vt.TypeID = pv.TypeID
GROUP BY ps.SpotID
HAVING SUM(vt.Size) = 1
ORDER BY ps.SpotID
)
END

IF @EmptySpot IS NULL
BEGIN
SET @EmptySpot = 
(
SELECT TOP 1 SpotID
FROM ParkingSpot 
WHERE SpotID NOT IN (SELECT SpotID FROM ParkedVehicle)
ORDER BY SpotID
)
END
RETURN
GO
/****** Object:  StoredProcedure [dbo].[GetFee]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFee]
@Regnum NVARCHAR(10), 
@FeeToPay MONEY OUTPUT
AS

DECLARE @MinutesParked DECIMAL = DATEDIFF(MINUTE, (SELECT InTime FROM ParkedVehicle WHERE Regnum=@Regnum), GETDATE())
IF @MinutesParked < 5
	SET @FeeToPay = 0

ELSE
	BEGIN
	DECLARE @HourlyRate INT = 
	(
	SELECT HourlyRate 
	FROM VehicleType v
	JOIN ParkedVehicle p
	ON v.TypeID = p.TypeID
	WHERE p.Regnum = @Regnum
	)

IF @MinutesParked - 5 < 125
	SET @FeeToPay = @HourlyRate * 2

ELSE
	SET @FeeToPay = (CEILING((@MinutesParked - 5)/60)) * @HourlyRate
END
RETURN
GO
/****** Object:  StoredProcedure [dbo].[Income interval]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Income interval]
@StartDate DATE, @EndDate DATE, @AverageIncome MONEY OUTPUT
AS
SELECT SUM(Fee) AS 'IncomePerDay'
INTO #IncomeDayTable
FROM VehicleHistory
WHERE CONVERT(DATE, OutTime) BETWEEN @StartDate AND @EndDate
GROUP BY CONVERT(DATE, OutTime)

SET @AverageIncome = (SELECT AVG(IncomePerDay)
FROM #IncomeDayTable)

DROP TABLE #IncomeDayTable;
RETURN
GO
/****** Object:  StoredProcedure [dbo].[MoveVehicle]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MoveVehicle]
@Regnum NVARCHAR(10), @ParkingSpot INT
AS

BEGIN TRANSACTION

DECLARE @ParkingSpotID INT = 
(
SELECT SpotID 
FROM ParkingSpot
WHERE SpotNumber = @ParkingSpot
)

DECLARE @CurrentSizeOfNewSpot INT = 
(
SELECT SUM(vt.Size) 
FROM ParkedVehicle pv
JOIN VehicleType vt 
ON pv.TypeID = vt.TypeID
WHERE pv.SpotID = @ParkingSpotID
)

DECLARE @VehicleSize INT = 
(
SELECT vt.Size 
FROM ParkedVehicle pv
JOIN VehicleType vt 
ON pv.TypeID = vt.TypeID
WHERE pv.Regnum = @Regnum
)

IF 
(
	SELECT COUNT(*) 
	FROM ParkedVehicle 
	WHERE Regnum = @Regnum
) = 0

BEGIN
RAISERROR('404 Vehicle Not Found...', 17, 1)
ROLLBACK TRANSACTION
END

ELSE IF @CurrentSizeOfNewSpot >= 2 OR (@CurrentSizeOfNewSpot = 1 AND @VehicleSize = 2)
BEGIN
RAISERROR('Sorry! Your vehicle is too big for that new spot...', 17, 1)
ROLLBACK TRANSACTION
END

ELSE
	BEGIN TRY
	UPDATE ParkedVehicle
	SET SpotID = @ParkingSpotID
	WHERE Regnum = @Regnum;

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
RAISERROR('Oh no, something went wrong! :(.', 17, 1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RemoveVehicle]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------------------

CREATE PROCEDURE [dbo].[RemoveVehicle] 
@Regnum NVARCHAR(10), 
@FeeToPay MONEY = NULL
AS

BEGIN TRANSACTION
IF @FeeToPay IS NULL
BEGIN
	EXECUTE [GetFee] @Regnum, @FeeToPay OUTPUT
END

BEGIN TRY
INSERT INTO VehicleHistory(Regnum, InTime, OutTime, Fee)
SELECT  Regnum, InTime, GETDATE(), @FeeToPay FROM ParkedVehicle
WHERE Regnum = @Regnum
DELETE FROM ParkedVehicle
WHERE Regnum = @Regnum;

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RemoveVehicleNoCost]    Script Date: 2021-02-05 12:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveVehicleNoCost]
@Regnum NVARCHAR(10), 
@FeeToPay MONEY = 0
AS

BEGIN TRANSACTION
IF @FeeToPay = 0
BEGIN TRY
	INSERT INTO VehicleHistory(Regnum, InTime, OutTime, Fee)
	SELECT Regnum, InTime, GETDATE(), @FeeToPay FROM ParkedVehicle
	WHERE Regnum = @Regnum
	DELETE FROM ParkedVehicle
	WHERE Regnum = @Regnum;

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
USE [master]
GO
ALTER DATABASE [PragueParking3] SET  READ_WRITE 
GO
