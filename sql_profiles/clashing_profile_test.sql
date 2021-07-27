REM clashing_profile_test.sql
spool clashing_profile_test
set pages 9999 lines 200 autotrace off trimspool on echo on
column name format a30
column category format a10
column created format a30
column last_modified format a30
column task_exec_name format a20
column signature format 99999999999999999999
column description format a20

DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('clashing_profile_test_force',TRUE);
exec dbms_sqltune.drop_sql_profile('clashing_profile_test_exact',TRUE);
select * from dba_sql_profiles where name like 'clashing%';


CREATE TABLE t (a not null, b) AS 
SELECT rownum, ceil(sqrt(rownum))
FROM dual
connect by level <= 100
/
create unique index t_idx on t(a)
/
create index t_idx2 on t(b,a)
/
exec dbms_stats.gather_table_stats(user,'T');

ttitle 'Default Execution plan without profiles (skip scan)'
select * from dba_sql_profiles where name like 'clashing%';
explain plan for
SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
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
name        => 'clashing_profile_test_force',
category    => 'DEFAULT',
validate    => TRUE,
replace     => TRUE,
force_match => TRUE 
);
END;
/

ttitle 'Execution plan with force matching profile (full scan)'
select * from dba_sql_profiles where name like 'clashing%';
explain plan for
SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
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
q'[INDEX(@"SEL$1" "T"@"SEL$1" ("T"."A"))]',
q'[END_OUTLINE_DATA]');
signature := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_txt);
DBMS_SQLTUNE.IMPORT_SQL_PROFILE (
sql_text    => sql_txt,
profile     => h,
name        => 'clashing_profile_test_exact',
category    => 'DEFAULT',
validate    => TRUE,
replace     => TRUE,
force_match => FALSE 
);
END;
/

ttitle 'Execution plan with force matching profile (unique index lookup)'
select * from dba_sql_profiles where name like 'clashing%';
explain plan for
SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
/
----------------------------------------------------------------------------------------------------
ttitle 'Execution plan with force matching profile (full scan)'
explain plan for
SELECT * FROM t WHERE a = 54;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
/
----------------------------------------------------------------------------------------------------
ttitle 'Disable Exact Profile - Execution plan with no profile (skip scan) - Odd'
exec dbms_sqltune.alter_sql_profile(name=>'clashing_profile_test_exact', attribute_name=>'STATUS',value=>'DISABLED');
select * from dba_sql_profiles where name like 'clashing%';

explain plan for
SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
/
----------------------------------------------------------------------------------------------------
ttitle 'Change Category of Exact Profile - Execution plan with force matching profile (full scan)'
--exec dbms_sqltune.drop_sql_profile('clashing_profile_test_exact',TRUE);
exec dbms_sqltune.alter_sql_profile(name=>'clashing_profile_test_exact', attribute_name=>'CATEGORY',value=>'DO_NOT_USE');
select * from dba_sql_profiles where name like 'clashing%';

explain plan for
SELECT * FROM t WHERE a = 42;
select * from table(dbms_xplan.display(null,null,'ADVANCED +ADAPTIVE -PROJECTION'))
/
----------------------------------------------------------------------------------------------------

spool off
DROP TABLE t PURGE;
exec dbms_sqltune.drop_sql_profile('clashing_profile_test_force',TRUE);
exec dbms_sqltune.drop_sql_profile('clashing_profile_test_exact',TRUE);
ttitle 'Test Profiles'
select * from dba_sql_profiles where name like 'clashing%';
ttitle off
