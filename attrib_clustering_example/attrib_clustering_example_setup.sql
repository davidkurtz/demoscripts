REM attrib_clustering_example_setup.sql
set lines 150 timi on echo on long 500 timi on
ttitle off
column owner format a8
column mview_name format a10
column container_name format a10
column segment_name format a10
column zonemap_name format a15
column fact_owner format a8
column fact_table format a10
column count(*) format 999,999,999
Alter session set nls_date_format = 'HH24:MI:SS dd.mm.yy';
alter session set current_schema=SYSADM;
clear screen
spool attrib_clustering_example_setup.lst

drop table t0 purge;
drop materialized view mv;
drop table mv purge;

create table t0(a varchar2(8 char), b varchar2(8 char), c varchar2(8 char), x number /*, constraint t0_pk primary key (a,b,c)*/);
create table mv(a varchar2(8 char), b varchar2(8 char), c varchar2(8 char), x number);
truncate table t0;
BEGIN
  FOR i IN 1..2 LOOP
    insert  /*+APPEND PARALLEL*/ into t0
    select  /*+PARALLEL*/
/*--------------------------------------------------------------------------------------------------------------
            rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(dbms_random.value(0,255)),'XX')),2,'0'),8,'X') a
    ,       rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(dbms_random.value(0,255)),'XX')),2,'0'),8,'X') b
    ,       rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(dbms_random.value(0,255)),'XX')),2,'0'),8,'X') c
--------------------------------------------------------------------------------------------------------------*/
            rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(SQRT(dbms_random.value(0,65535))),'XX')),2,'0'),8,'X') a
    ,       rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(SQRT(dbms_random.value(0,65535))),'XX')),2,'0'),8,'X') b
    ,       rPAD(LPAD(LTRIM(TO_CHAR(FLOOR(SQRT(dbms_random.value(0,65535))),'XX')),2,'0'),8,'X') c
--------------------------------------------------------------------------------------------------------------*/
    ,       dbms_random.value(1,1e6)
    from dual
    connect by level <= 1e7;
    COMMIT;
  end loop;
end;
/

exec dbms_stats.gather_table_stats(user,'T0');
select count(*) from t0;


create materialized view mv
ON PREBUILT TABLE 
--BUILD DEFERRED
ENABLE QUERY REWRITE
as select * from t0;

alter table MV nocompress;
alter table mv noinmemory;
alter table mv drop clustering;

ttitle mviews
select * from user_mviews where mview_name = 'MV';
spool off

show user
select count(*) from t0;
select /*+NO_REWRITE*/ count(*) from t0;

spool off
