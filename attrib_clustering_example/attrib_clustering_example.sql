REM attrib_clustering_example.sql
set lines 150 timi on echo on long 500 pages 99
ttitle off
column owner format a8
column mview_name format a10 heading 'MView|Name'
column table_name format a10 heading 'Table|Name'
column container_name format a10 heading 'Container|Name'
column segment_name format a10 heading 'Segment Name'
column segment_type format a10 heading 'Segment Type'
column zonemap_name format a15 heading 'Zone Map Name'
column fact_owner format a8 heading 'Fact|Owner'
column fact_table format a10 heading 'Fact|Table'
column update_log format a10
column master_Rollback_seg format a10
column master_link format a10
column evaluation_edition format a10
column unusable_before format a10 heading 'Unusable|Before'
column unusable_beginning format a10 heading 'Unusable|Beginning'
column default_collation format a10
column partition_name format a10 heading 'Partition|Name'
column tablespace_name format a10 heading 'Tablespace|Name'
COLUMN Table_MB FORMAT 999,999.9 HEADING 'Table|MB'
COLUMN TABLESPACE_MB FORMAT 999,999.9 HEADING 'Tablespace|MB'
COLUMN INMEMORY_mb FORMAT 999,999.9 heading 'In Memory|MB'
Alter session set nls_date_format = 'HH24:MI:SS dd.mm.yy';
alter session set current_schema=SYSADM;
clear screen
spool attrib_clustering_example.20muniform.10.querylow.nointerleaved.lst
truncate table MV drop storage;
alter table MV pctfree 0;
--------------------------------------------------
rem set compression
--------------------------------------------------
--alter materialized view MV nocompress;
--alter materialized view MV compress;
alter materialized view MV compress for query low;
--------------------------------------------------
rem set in memory
--------------------------------------------------
alter table mv inmemory;
--------------------------------------------------
rem set clustering
--------------------------------------------------
alter table mv drop clustering;
--alter table mv add clustering by interleaved order (b);
--alter table mv add clustering by interleaved order (b, c);
--alter table mv add clustering by interleaved order (b, c, a);
--alter table mv modify clustering without materialized zonemap;
--alter table mv add clustering by linear order (a, b);
--------------------------------------------------

exec dbms_mview.refresh('MV',atomic_refresh=>FALSE);
exec dbms_inmemory.repopulate(user,'MV');
EXEC DBMS_SESSION.sleep(10);
ttitle mviews
select * from user_mviews where mview_name = 'MV';
ttitle tables
select table_name, tablespace_name, num_rows, blocks, compression, compress_for, inmemory, inmemory_compression from user_tables where table_name IN('MV','T0');
ttitle segments
select segment_name, segment_type, tablespace_name, bytes/1024/1024 table_MB, blocks, extents, inmemory, inmemory_compression from user_Segments where segment_name IN('MV','T0');
ttitle zonemaps
select * from user_zonemaps where fact_table = 'MV';
ttitle inmemory
with x as (
select segment_type, owner, segment_name
, inmemory_compression, inmemory_priority
, count(distinct inst_id) instances
, count(distinct segment_type||':'||owner||'.'||segment_name||'.'||partition_name) segments
, sum(inmemory_size)/1024/1024 inmemory_mb
, sum(bytes)/1024/1024 tablespace_Mb
from   gv$im_segments i
where segment_name = 'MV'
group by segment_type, owner, segment_name, inmemory_compression, inmemory_priority
)
select x.*, inmemory_mb/tablespace_mb*100-100 pct
from x
order by owner, segment_type, segment_name
/

ttitle data
select b,c, count(a), sum(x)
from t0
where b='2AXXXXXX'
group by b,c
fetch first 10 rows only;
ttitle off
ttitle Summary
select sum(x), count(x) from mv;

--pause
explain plan for
select b,c, sum(x)
from t0
where b='2AXXXXXX'
group by b,c
/
set pages 9999 lines 200 autotrace off
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
/
spool off


