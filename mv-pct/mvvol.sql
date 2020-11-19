REM mvvol.sql

set autotrace off
break on table_name skip 1 on partition_name
column table_name format a15
column column_name format a20
column mview_name format a15
column partition_position format 999 heading 'Part|Pos'
column subpartition_position format 999 heading 'Sub-|Part|Pos'
column partition_name format a20
column subpartition_name format a25
column num_rows format 9999999
column num_distinct heading 'Num|Distinct' format 9999999
column num_buckets heading 'Num|Buckets'  format 9999
column blocks format 99999
column rpb format 999.9 heading 'Rows|per|Block'
SELECT MVIEW_NAME, STALENESS, LAST_REFRESH_TYPE, COMPILE_STATE FROM USER_MVIEWS ORDER BY MVIEW_NAME;

select count(*) from mv_ledger_2019;
select count(*) from mv_ledger_2020;

select a.table_name, a.partition_position, a.partition_name, a.subpartition_position, a.subpartition_name
, a.num_rows, a.blocks, a.num_rows/nullif(a.blocks,0) rpb
, COALESCE(c.compression, b.compression) compression
, COALESCE(c.compress_for, b.compress_for) compress_for
from user_tab_statistics a
  LEFT OUTER JOIN user_tab_partitions b
    ON a.table_name = b.table_name
    AND a.partition_name = b.partition_name
  LEFT OUTER JOIN user_tab_subpartitions c
    ON a.table_name = c.table_name
    AND a.partition_name = c.partition_name
    AND a.subpartition_name = c.subpartition_name
where a.table_name like '%LEDGER%'
order by a.table_name, a.partition_position, a.subpartition_position nulls first
/

column extension format a40
select s.table_name, s.column_name, s.num_distinct, s.num_buckets, s.histogram, s.last_analyzed, e.extension
from user_tab_col_statistics s
  LEFT OUTER JOIN user_stat_extensions e
  ON e.table_name = s.table_name
  AND e.extension_name = s.column_name
where s.table_name like 'MV_LEDGER%'
order by 1,2
;
column extension format a40
select s.table_name, s.partition_name, s.column_name, s.num_distinct, s.num_buckets, s.histogram, s.last_analyzed, e.extension
from user_part_col_statistics s
  LEFT OUTER JOIN user_stat_extensions e
  ON e.table_name = s.table_name
  AND e.extension_name = s.column_name
where s.table_name like 'MV_LEDGER%'
order by 1,2
;

column extension format a40
select s.table_name, s.subpartition_name, s.column_name, s.num_distinct, s.num_buckets, s.histogram, s.last_analyzed, e.extension
from user_subpart_col_statistics s
  LEFT OUTER JOIN user_stat_extensions e
  ON e.table_name = s.table_name
  AND e.extension_name = s.column_name
where s.table_name like 'MV_LEDGER%'
order by 1,2
;
