REM convert_to_force_match.sql
REM see https://blog.go-faster.co.uk/2021/07/alter-sql-profiles-from-exact-to-force.html
spool convert_to_force_match
clear screen 
set pages 9999 lines 200 autotrace off trimspool on echo on
column name format a30
column category format a10
column created format a30
column last_modified format a30
column task_exec_name format a20
column signature format 99999999999999999999
column description format a20
----------------------------------------------------------------------------------------------------
DROP TABLE stage PURGE;
DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('my_sql_profile',TRUE);
exec dbms_sqltune.drop_sql_profile('my_old_sql_profile',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_force',TRUE);
----------------------------------------------------------------------------------------------------
CREATE TABLE t (a not null, b) AS 
SELECT rownum, ceil(sqrt(rownum)) FROM dual connect by level <= 100;
create unique index t_idx on t(a);
exec dbms_stats.gather_table_stats(user,'T');

ttitle off
select * from dba_sql_profiles where name like 'my%sql_profile%';
explain plan for SELECT * FROM t WHERE a = 42;
ttitle 'Default Execution plan without profiles (index scan)'
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));
----------------------------------------------------------------------------------------------------
DECLARE
signature INTEGER;
sql_txt CLOB;
h       SYS.SQLPROF_ATTR;
BEGIN
sql_txt := q'[
SELECT * FROM t WHERE a = 54
]';
h := SYS.SQLPROF_ATTR(
q'[BEGIN_OUTLINE_DATA]',
q'[IGNORE_OPTIM_EMBEDDED_HINTS]',
q'[FULL(@"SEL$1" "T"@"SEL$1")]',
q'[END_OUTLINE_DATA]');
signature := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_txt);
DBMS_SQLTUNE.IMPORT_SQL_PROFILE (
sql_text    => sql_txt,
profile     => h,
name        => 'my_sql_profile',
category    => 'DEFAULT',
validate    => TRUE,
replace     => TRUE,
force_match => FALSE 
);
END;
/
----------------------------------------------------------------------------------------------------
DECLARE
signature INTEGER;
sql_txt CLOB;
h       SYS.SQLPROF_ATTR;
BEGIN
sql_txt := q'[
SELECT * FROM t WHERE a = 54
]';
h := SYS.SQLPROF_ATTR(
q'[BEGIN_OUTLINE_DATA]',
q'[IGNORE_OPTIM_EMBEDDED_HINTS]',
q'[FULL(@"SEL$1" "T"@"SEL$1")]',
q'[END_OUTLINE_DATA]');
signature := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_txt);
DBMS_SQLTUNE.IMPORT_SQL_PROFILE (
sql_text    => sql_txt,
profile     => h,
name        => 'my_sql_profile_force',
category    => 'DEFAULT',
validate    => TRUE,
replace     => TRUE,
force_match => TRUE 
);
END;
/
----------------------------------------------------------------------------------------------------
ttitle off
select * from dba_sql_profiles where name like 'my%sql_profile%';
explain plan for SELECT * FROM t WHERE a = 42;
ttitle 'Execution plan with force match profile (full scan)'
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));

explain plan for SELECT * FROM t WHERE a = 54;
ttitle 'Execution plan with exact match profile (full scan - exact takes precedence over force)'
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));
----------------------------------------------------------------------------------------------------
REM How to Move SQL Profiles from One Database to Another (Including to Higher Versions) (Doc ID 457531.1)
REM https://support.oracle.com/epmos/faces/DocContentDisplay?id=457531.1
----------------------------------------------------------------------------------------------------
exec DBMS_SQLTUNE.CREATE_STGTAB_SQLPROF(table_name=>'STAGE',schema_name=>user);
--desc stage
truncate table stage;
exec DBMS_SQLTUNE.PACK_STGTAB_SQLPROF (staging_table_name =>'STAGE',profile_name=>'my_sql_profile');
exec DBMS_SQLTUNE.PACK_STGTAB_SQLPROF (staging_table_name =>'STAGE',profile_name=>'my_sql_profile_force');
--select * from stage;
select signature, sql_handle, obj_name, obj_type, sql_text, sqlflags from STAGE;
REM by planing spot the difference I can see SQL_FLAGS different for force matched profile

/*
variable force boolean
UPDATE stage
set sqlflags = 1
, signature = dbms_sqltune.sqltext_to_signature(sql_text,TRUE);
WHERE sqlflags = 0
/
*/

DECLARE
  l_sig INTEGER;
BEGIN
  FOR i IN (
    SELECT rowid, stage.* FROM stage WHERE sqlflags = 0 FOR UPDATE
  ) LOOP
    l_sig := dbms_sqltune.sqltext_to_signature(i.sql_text,TRUE);
    UPDATE stage
    SET    signature = l_sig
    ,      sqlflags = 1
    WHERE  sqlflags = 0
    AND    rowid = i.rowid;
  END LOOP;
END;
/
select signature, sql_handle, obj_name, obj_type, sql_text, sqlflags from STAGE;
----------------------------------------------------------------------------------------------------
REM ORA-13841: SQL profile named my_sql_profile already exists for a different signature/category pair
REM to avoid this error you must either drop or rename profile
REM I am going to disable it and move it to another category to keep it out of the way in case I want to go back to it later
----------------------------------------------------------------------------------------------------
exec dbms_sqltune.alter_sql_profile(name=>'my_sql_profile', attribute_name=>'NAME',value=>'my_old_sql_profile');
exec dbms_sqltune.alter_sql_profile(name=>'my_old_sql_profile', attribute_name=>'CATEGORY',value=>'DO_NOT_USE');
exec dbms_sqltune.alter_sql_profile(name=>'my_old_sql_profile', attribute_name=>'STATUS',value=>'DISABLED');
exec dbms_sqltune.drop_sql_profile('my_sql_profile_force',TRUE);
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF(profile_name => 'my_sql_profile', replace => TRUE, staging_table_name => 'STAGE');

----------------------------------------------------------------------------------------------------
ttitle off
select * from dba_sql_profiles where name like 'my%sql_profile%';
explain plan for SELECT * FROM t WHERE a = 42;
ttitle 'Execution plan with force match profile (full scan)'
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));
explain plan for SELECT * FROM t WHERE a = 54;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));
----------------------------------------------------------------------------------------------------
spool off
----------------------------------------------------------------------------------------------------
DROP TABLE stage PURGE;
DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('my_sql_profile',TRUE);
exec dbms_sqltune.drop_sql_profile('my_old_sql_profile',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_force',TRUE);
----------------------------------------------------------------------------------------------------

