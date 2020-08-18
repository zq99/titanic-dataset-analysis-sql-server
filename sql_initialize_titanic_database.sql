Use [titanic]
GO

DROP FUNCTION IF EXISTS [dbo].[fn_clean]
GO

CREATE FUNCTION [dbo].[fn_clean] (@text nvarchar(500))
RETURNS nvarchar(50) AS
BEGIN
	return LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(@text, CHAR(10), CHAR(32)),CHAR(13), CHAR(32)),CHAR(160), CHAR(32)),CHAR(9),CHAR(32))))
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP FUNCTION IF EXISTS [dbo].[fn_get_age_bracket]
GO

CREATE FUNCTION [dbo].[fn_get_age_bracket] (@age decimal)
RETURNS nvarchar(500) AS
BEGIN
	return
	case when @age < 1.0 then '<1' 
		 when @age >= 1.0 and @age < 10.0 then '01-09'
		 when @age >= 10.0 and @age < 20.0 then '10-19'
		 when @age >= 20.0 and @age < 30.0 then '20-29'
		 when @age >= 30.0 and @age < 40.0 then '30-39'
		 when @age >= 40.0 and @age < 50.0 then '40-49'
		 when @age >= 50.0 and @age < 60.0 then '50-59'
		 when @age >= 60.0 and @age < 70.0 then '60-69'
		 when @age >= 70.0 and @age < 80.0 then '70-79'
		 when @age >= 80.0 and @age < 90.0 then '80-89'
		 when @age >= 90 then 'over 90'
		 else 'unknown'
		 end
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_alias]
GO

CREATE FUNCTION [dbo].[fn_get_alias] (@passenger_name nvarchar(500))
RETURNS nvarchar(500) AS
BEGIN
	return substring(@passenger_name,charindex('"',@passenger_name,1),charindex('"',@passenger_name,charindex('"',@passenger_name,1)+1) - charindex('"',@passenger_name,1)+1)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP FUNCTION IF EXISTS [dbo].[fn_get_cabin_number_location_on_deck] 
GO

CREATE FUNCTION [dbo].[fn_get_cabin_number_location_on_deck] (@cabin_number int)
RETURNS nvarchar(500) AS
BEGIN
	return
	case 
		 when @cabin_number >= 1 and @cabin_number <= 49 then 'front'
		 when @cabin_number >= 50 and @cabin_number <= 99 then 'middle'
		 when @cabin_number >= 100 then 'rear'
		 else 'unknown'
		 end
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_count_of_character_in_string]
GO

CREATE FUNCTION [dbo].[fn_get_count_of_character_in_string] (@character nvarchar(1),@text nvarchar(500))
RETURNS int AS
BEGIN
	return len(@text) - len(replace(@text,@character,''))
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_name_sans_title]
GO

CREATE FUNCTION [dbo].[fn_get_name_sans_title] (@passenger_name nvarchar(500))
RETURNS nvarchar(500) AS
BEGIN
	return replace(@passenger_name,substring(@passenger_name,charindex(',',@passenger_name,1)+1,charindex('.',@passenger_name,1)-charindex(',',@passenger_name,1)),'')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_name_sans_title_alias]
GO

CREATE FUNCTION [dbo].[fn_get_name_sans_title_alias] (@passenger_name nvarchar(500))
RETURNS nvarchar(500) AS
BEGIN
	DECLARE @name_sans_title nvarchar(500) = [dbo].fn_get_name_sans_title(@passenger_name)
	DECLARE @alias nvarchar(500) = [dbo].fn_get_alias(@passenger_name)
	return replace(replace(@name_sans_title,@alias,''),'()','')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_percent]
GO

CREATE FUNCTION [dbo].[fn_get_percent] (@numerator int, @denominator int)
RETURNS float AS
BEGIN
	 
	if @denominator > 0
		return round((cast(@numerator as float) / cast(@denominator as float)),3) * 100

	return cast(0 as float)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_surname]
GO

CREATE FUNCTION [dbo].[fn_get_surname] (@passenger_name nvarchar(500))
RETURNS nvarchar(500) AS
BEGIN
	return substring(@passenger_name,1,charindex(',',@passenger_name,1)-1)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_get_title_from_name]
GO

CREATE FUNCTION [dbo].[fn_get_title_from_name] (@passenger_name nvarchar(500))
RETURNS nvarchar(50) AS
BEGIN
	return ltrim(rtrim(substring(@passenger_name,charindex(',',@passenger_name,1)+1,charindex('.',@passenger_name,1)-charindex(',',@passenger_name,1)-1)))
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP FUNCTION IF EXISTS [dbo].[fn_remove_deck_from_cabin]
GO

CREATE FUNCTION [dbo].[fn_remove_deck_from_cabin] (@cabin nvarchar(500))
RETURNS nvarchar(50) AS
BEGIN
	return replace(replace(replace(replace(replace(replace(replace(replace(@cabin,'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'T','')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP TABLE IF EXISTS [dbo].[train]
GO

CREATE TABLE [dbo].[train](
	[passengerId] [int] NOT NULL,
	[survived] [int] NULL,
	[pclass] [int] NULL,
	[name] [nvarchar](200) NULL,
	[sex] [nvarchar](50) NULL,
	[age] [int] NULL,
	[sibsp] [nvarchar](50) NULL,
	[parch] [nvarchar](50) NULL,
	[ticket] [nvarchar](50) NULL,
	[fare] [float] NULL,
	[cabin] [nvarchar](50) NULL,
	[embarked] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP VIEW IF EXISTS [dbo].[vw_missing_data_analysis]
GO

create view [dbo].[vw_missing_data_analysis]
as
select d.*, round(cast(d.filled as float) / d.total,3) * 100 as perc_filled, round(cast(d.missing as float) / d.total,3) * 100 as perc_missing 

from

(
  select 'Age' as variable, count(PassengerId) as total, sum(case when Age is not null then 1 else 0 end) as filled, sum(case when Age is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Sex' as variable, count(PassengerId) as total, sum(case when Sex is not null then 1 else 0 end) as filled, sum(case when Sex is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Pclass' as variable, count(PassengerId) as total, sum(case when Pclass is not null then 1 else 0 end) as filled, sum(case when Pclass is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'SibSp' as variable, count(PassengerId) as total, sum(case when SibSp is not null then 1 else 0 end) as filled, sum(case when SibSp is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Parch' as variable, count(PassengerId) as total, sum(case when Parch is not null then 1 else 0 end) as filled, sum(case when Parch is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Ticket' as variable, count(PassengerId) as total, sum(case when Ticket is not null then 1 else 0 end) as filled, sum(case when Ticket is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train] 
  union
  select 'Fare' as variable, count(PassengerId) as total, sum(case when Fare is not null then 1 else 0 end) as filled, sum(case when Fare is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Cabin' as variable, count(PassengerId) as total, sum(case when Cabin is not null then 1 else 0 end) as filled, sum(case when Cabin is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
  union
  select 'Embarked' as variable, count(PassengerId) as total, sum(case when Embarked is not null then 1 else 0 end) as filled, sum(case when Embarked is null then 1 else 0 end) as missing
  from [titanic].[dbo].[train]
) d
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP TABLE IF EXISTS [dbo].[test]
GO

CREATE TABLE [dbo].[test](
	[PassengerId] [int] NULL,
	[Pclass] [int] NULL,
	[Name] [nvarchar](100) NULL,
	[Sex] [nvarchar](50) NULL,
	[Age] [decimal](18, 0) NULL,
	[SibSp] [nvarchar](50) NULL,
	[Parch] [nvarchar](50) NULL,
	[Ticket] [nvarchar](50) NULL,
	[Fare] [float] NULL,
	[Cabin] [nvarchar](50) NULL,
	[Embarked] [nvarchar](50) NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP VIEW IF EXISTS [dbo].[vw_train_and_test_combined]
GO

CREATE view [dbo].[vw_train_and_test_combined]
as
SELECT [passengerId]
      ,[survived]
      ,[pclass]
      ,[name]
      ,[sex]
      ,[age]
      ,[sibsp]
      ,[parch]
      ,[ticket]
      ,[fare]
      ,[cabin]
      ,[embarked]
	  ,'train' as [dataset]
  FROM [titanic].[dbo].[train]
  UNION
  SELECT [PassengerId]
      ,null as [survived]
      ,[Pclass]
      ,[Name]
      ,[Sex]
      ,[Age]
      ,[SibSp]
      ,[Parch]
      ,[Ticket]
      ,[Fare]
      ,[Cabin]
      ,[Embarked]
	  ,'test' as [dataset]
  FROM [titanic].[dbo].[test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



DROP VIEW IF EXISTS [dbo].[vw_table_row_counts]
GO

create view [dbo].[vw_table_row_counts]
as

SELECT t.name, s.row_count from sys.tables t
JOIN sys.dm_db_partition_stats s
ON t.object_id = s.object_id
AND t.type_desc = 'USER_TABLE'
AND t.name not like '%dss%'
AND s.index_id IN (0,1)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP TABLE IF EXISTS [dbo].[test_bcp]
GO

CREATE TABLE [dbo].[test_bcp](
	[PassengerId] [nvarchar](50) NULL,
	[Pclass] [nvarchar](50) NULL,
	[Name1] [nvarchar](100) NULL,
	[Name2] [nvarchar](100) NULL,
	[Sex] [nvarchar](50) NULL,
	[Age] [nvarchar](50) NULL,
	[SibSp] [nvarchar](50) NULL,
	[Parch] [nvarchar](50) NULL,
	[Ticket] [nvarchar](50) NULL,
	[Fare] [nvarchar](50) NULL,
	[Cabin] [nvarchar](50) NULL,
	[Embarked] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP TABLE IF EXISTS [dbo].[train_bcp]
GO

CREATE TABLE [dbo].[train_bcp](
	[PassengerId] [nvarchar](50) NULL,
	[Survived] [nvarchar](50) NULL,
	[Pclass] [nvarchar](50) NULL,
	[Name1] [nvarchar](200) NULL,
	[Name2] [nvarchar](200) NULL,
	[Sex] [nvarchar](50) NULL,
	[Age] [nvarchar](50) NULL,
	[SibSp] [nvarchar](50) NULL,
	[Parch] [nvarchar](50) NULL,
	[Ticket] [nvarchar](50) NULL,
	[Fare] [nvarchar](50) NULL,
	[Cabin] [nvarchar](50) NULL,
	[Embarked] [nvarchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP PROCEDURE IF EXISTS [dbo].[sp_cleardown_import_data]
GO

CREATE PROCEDURE [dbo].[sp_cleardown_import_data]
AS

delete from [dbo].[test]
delete from [dbo].[test_bcp]
delete from [dbo].[train]
delete from [dbo].[train_bcp]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP PROCEDURE IF EXISTS [dbo].[sp_import_test_csv]
GO

CREATE PROCEDURE [dbo].[sp_import_test_csv](@file_name nvarchar(500))
AS

delete from test_bcp

declare @sql varchar(max)

set @sql = 'bulk insert test_bcp
			from ''' + @file_name + ''' with (FIELDTERMINATOR = '','', ROWTERMINATOR =''0x0a'',FIRSTROW = 0)'
exec (@sql)

delete from test

insert into test
select cast(PassengerId as int) as passengerId
	  ,cast(Pclass as int) as pclass
      ,replace(Name1,'"','') + ',' + replace(Name2,'"','') as [name]
	  ,Sex
	  ,cast(Age as decimal) as age
	  ,SibSp as sibp,Parch as parch,Ticket as ticket
	  ,cast(Fare as float) as fare
	  ,Cabin as cabin
	  ,[dbo].[fn_clean](embarked) as embarked

from [titanic].[dbo].[test_bcp]
order by cast(PassengerId as int) asc

DECLARE @row_count_bcp SMALLINT;DECLARE @row_count SMALLINT;
set @row_count_bcp = (select count(*) from test_bcp)
set @row_count = (select count(*) from test)

print('rows imported           : ' + cast(@row_count_bcp as nvarchar(10)))
print('rows added to main table: ' + cast(@row_count as nvarchar(10)))

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



DROP PROCEDURE IF EXISTS [dbo].[sp_import_train_csv]
GO

CREATE PROCEDURE [dbo].[sp_import_train_csv](@file_name nvarchar(500))
AS

delete from train_bcp

declare @sql varchar(max)

set @sql = 'bulk insert train_bcp
			from ''' + @file_name + ''' with (FIELDTERMINATOR = '','', ROWTERMINATOR =''0x0a'',FIRSTROW = 0)'
exec (@sql)

delete from train

insert into train
select cast(PassengerId as int) as passengerId
      ,cast(Survived as int) as survived
	  ,cast(Pclass as int) as pclass
      ,replace(Name1,'"','') + ',' + replace(Name2,'"','') as [name]
	  ,Sex
	  ,cast(Age as decimal) as age
	  ,SibSp as sibp,Parch as parch,Ticket as ticket
	  ,cast(Fare as float) as fare
	  ,Cabin as cabin
	  ,[dbo].[fn_clean](embarked) as embarked

from [titanic].[dbo].[train_bcp]
order by cast(PassengerId as int) asc

DECLARE @row_count_bcp SMALLINT;DECLARE @row_count SMALLINT;
set @row_count_bcp = (select count(*) from train_bcp)
set @row_count = (select count(*) from train)

print('rows imported           : ' + cast(@row_count_bcp as nvarchar(10)))
print('rows added to main table: ' + cast(@row_count as nvarchar(10)))

GO
USE [master]
GO
ALTER DATABASE [titanic] SET  READ_WRITE 
GO
