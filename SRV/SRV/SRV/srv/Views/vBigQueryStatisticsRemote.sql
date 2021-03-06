﻿
create view [srv].[vBigQueryStatisticsRemote]
as
SELECT [Server]
      ,[creation_time]
      ,[last_execution_time]
      ,[execution_count]
      ,[CPU]
      ,[AvgCPUTime]
      ,[TotDuration]
      ,[AvgDur]
      ,[AvgIOLogicalReads]
      ,[AvgIOLogicalWrites]
      ,[AggIO]
      ,[AvgIO]
      ,[AvgIOPhysicalReads]
      ,[plan_generation_num]
      ,[AvgRows]
      ,[AvgDop]
      ,[AvgGrantKb]
      ,[AvgUsedGrantKb]
      ,[AvgIdealGrantKb]
      ,[AvgReservedThreads]
      ,[AvgUsedThreads]
      ,[query_text]
      ,[database_name]
      ,[object_name]
      ,cast([query_plan] as nvarchar(max)) as [query_plan]
      ,[sql_handle]
      ,[plan_handle]
      ,[query_hash]
      ,[query_plan_hash]
      ,[InsertUTCDate]
  FROM [srv].[BigQueryStatistics]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тяжелые запросы для удаленного сбора', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vBigQueryStatisticsRemote';

