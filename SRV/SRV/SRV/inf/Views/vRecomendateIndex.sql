﻿

CREATE   view [inf].[vRecomendateIndex] as

-- Отсутствующие индексы из DMV

SELECT  cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)) AS ServerName ,
        DB_Name(ddmid.[database_id]) as [DBName] ,
        t.name AS 'Affected_table' ,
		ddmigs.user_seeks * ddmigs.avg_total_user_cost * (ddmigs.avg_user_impact * 0.01) AS index_advantage,
		ddmigs.group_handle,
		ddmigs.unique_compiles,
		ddmigs.last_user_seek,
		ddmigs.last_user_scan,
		ddmigs.avg_total_user_cost,
		ddmigs.avg_user_impact,
		ddmigs.system_seeks,
		ddmigs.last_system_scan,
		ddmigs.last_system_seek,
		ddmigs.avg_total_system_cost,
		ddmigs.avg_system_impact,
		ddmig.index_group_handle,
		ddmig.index_handle,
		ddmid.database_id,
		ddmid.[object_id],
		ddmid.equality_columns,	  -- =
		ddmid.inequality_columns,
		ddmid.[statement],
        ( LEN(ISNULL(ddmid.equality_columns, N'')
              + CASE WHEN ddmid.equality_columns IS NOT NULL
                          AND ddmid.inequality_columns IS NOT NULL THEN ','
                     ELSE ''
                END) - LEN(REPLACE(ISNULL(ddmid.equality_columns, N'')
                                   + CASE WHEN ddmid.equality_columns
                                                             IS NOT NULL
                                               AND ddmid.inequality_columns
                                                             IS NOT NULL
                                          THEN ','
                                          ELSE ''
                                     END, ',', '')) ) + 1 AS K ,
        COALESCE(ddmid.equality_columns, '')
        + CASE WHEN ddmid.equality_columns IS NOT NULL
                    AND ddmid.inequality_columns IS NOT NULL THEN ','
               ELSE ''
          END + COALESCE(ddmid.inequality_columns, '') AS Keys ,
        ddmid.included_columns AS [include] ,
        'Create NonClustered Index IX_' + t.name + '_missing_'
        + CAST(ddmid.index_handle AS VARCHAR(20)) 
        + ' On ' + ddmid.[statement] COLLATE database_default
        + ' (' + ISNULL(ddmid.equality_columns, '')
        + CASE WHEN ddmid.equality_columns IS NOT NULL
                    AND ddmid.inequality_columns IS NOT NULL THEN ','
               ELSE ''
          END + ISNULL(ddmid.inequality_columns, '') + ')'
        + ISNULL(' Include (' + ddmid.included_columns + ');', ';')
                                                  AS sql_statement ,
        ddmigs.user_seeks ,
        ddmigs.user_scans ,
        CAST(( ddmigs.user_seeks + ddmigs.user_scans )
        * ddmigs.avg_user_impact AS BIGINT) AS 'est_impact' ,
        ( SELECT    DATEDIFF(Second, create_date, GETDATE()) Seconds
          FROM      sys.databases
          WHERE     name = 'tempdb'
        ) SecondsUptime 
FROM    sys.dm_db_missing_index_groups ddmig
        INNER JOIN sys.dm_db_missing_index_group_stats ddmigs
               ON ddmigs.group_handle = ddmig.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details ddmid
               ON ddmig.index_handle = ddmid.index_handle
        INNER JOIN sys.tables t ON ddmid.OBJECT_ID = t.OBJECT_ID
WHERE   ddmid.database_id = DB_ID()
--ORDER BY est_impact DESC;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отсутствующие индексы из DMV', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vRecomendateIndex';

