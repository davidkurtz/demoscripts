REM dup_profiles_test.sql
spool dup_profiles_test
clear screen 
ttitle off
break on report
set pages 9999 lines 160 autotrace off trimspool on echo on
column name format a30
column category format a10
column created format a30
column sql_Text format a50
column last_modified format a30
column task_exec_name format a20
column signature format 99999999999999999999
column description format a20
----------------------------------------------------------------------------------------------------
DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('my_sql_profile_24',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_42',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_54',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_force',TRUE);
/*----------------------------------------------------------------------------------------------------
CREATE TABLE t (a not null, b) AS 
SELECT rownum, ceil(sqrt(rownum)) FROM dual connect by level <= 100;
create unique index t_idx on t(a);
exec dbms_stats.gather_table_stats(user,'T');

select * from dba_sql_profiles where name like 'my%sql_profile%';
explain plan for SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'));
----------------------------------------------------------------------------------------------------*/
DECLARE
signature INTEGER;
sql_txt CLOB;
h       SYS.SQLPROF_ATTR;
BEGIN
sql_txt := q'[
SELECT * FROM t 
WHERE a = 24
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
name        => 'my_sql_profile_24',
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
SELECT * FROM t WHERE a = 42
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
name        => 'my_sql_profile_42',
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
select * from dba_sql_profiles;
----------------------------------------------------------------------------------------------------
@@dup_sql_profiles1.sql
@@dup_sql_profiles2.sql
----------------------------------------------------------------------------------------------------
spool off

----------------------------------------------------------------------------------------------------
DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('my_sql_profile_24',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_42',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_54',TRUE);
exec dbms_sqltune.drop_sql_profile('my_sql_profile_force',TRUE);
----------------------------------------------------------------------------------------------------
