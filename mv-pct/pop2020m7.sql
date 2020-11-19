REM pop2020m7.sql
set autotrace off
insert into ps_ledger
with n as (
SELECT rownum n from dual connect by level <= 1e6/13
--), fy as (
--SELECT 2017+rownum fiscal_year FROM dual CONNECT BY level <= 4
--), ap as (
--SELECT FLOOR(dbms_random.value(0,13)) accounting_period FROM dual connect by level <= 998
--UNION ALL SELECT 998 FROM DUAL CONNECT BY LEVEL <= 1
--UNION ALL SELECT 999 FROM DUAL CONNECT BY LEVEL <= 1
--), l as (
--SELECT 'ACTUALS' ledger FROM DUAL CONNECT BY LEVEL <= 10
--UNION ALL SELECT 'BUDGET' FROM DUAL
)
select 'BU'||LTRIM(TO_CHAR(CASE WHEN dbms_random.value <= .9 THEN 1 ELSE 2 END,'000')) business_unit 
,      'ACTUALS' ledger
,      'ACC'||LTRIM(TO_CHAR(999*SQRT(dbms_random.value),'000')) account 
,      'ALTACCT'||LTRIM(TO_CHAR(999*dbms_random.value,'000')) altacct
,      'DEPT'||LTRIM(TO_CHAR(9999*dbms_random.value,'0000')) deptid
,      'OPUNIT'||LTRIM(TO_CHAR(99*dbms_random.value,'00')) operating_unit
,      'P'||LTRIM(TO_CHAR(99999*dbms_random.value,'00000')) product 
,      'FUND'||LTRIM(TO_CHAR(9*dbms_random.value,'0')) fund_code
,      'CLAS'||LTRIM(TO_CHAR(9*dbms_random.value,'0')) class_fld
,      'PROD'||LTRIM(TO_CHAR(9*dbms_random.value,'0')) program_code
,      ' ' budget_ref
,      'AF'||LTRIM(TO_CHAR(999*dbms_random.value,'000')) affiliate 
,      'AFI'||LTRIM(TO_CHAR(99999*dbms_random.value,'00000')) affiliate_intra1
,      'AFI'||LTRIM(TO_CHAR( 9999*dbms_random.value,'0000')) affiliate_intra2
,      'CF'||LTRIM(TO_CHAR(  999*SQRT(dbms_random.value),'000')) chartfield1
,      'CF'||LTRIM(TO_CHAR(99999*dbms_random.value,'00000')) chartfield2
,      'CF'||LTRIM(TO_CHAR( 9999*dbms_random.value,'0000')) chartfield3
,      'PRJ'||LTRIM(TO_CHAR(9999*dbms_random.value,'0000')) project_id
,      'BK'||LTRIM(TO_CHAR(99*dbms_random.value,'00')) book_code
,      'GL'||LTRIM(TO_CHAR(99*dbms_random.value,'00')) gl_adjust_type
,      'GBP' currency_cd 
,      ' ' statistics_code 
,      2020 fiscal_year
,      7 accounting_period
,      dbms_random.value(0,1e6) posted_total_amt 
,      0 posted_base_amt 
,      0 posted_tran_amt 
,      'GBP' base_currency 
,      SYSDATE dttm_stamp_sec
,      0 process_instance 
FROM   n
--WHERE  l.ledger = 'ACTUALS' 
--AND    fy.fiscal_year = 2020
--AND    ap.accounting_period = 7
/
set lines 200 pages 999 autotrace off
SELECT MVIEW_NAME, STALENESS, LAST_REFRESH_TYPE, COMPILE_STATE FROM USER_MVIEWS ORDER BY MVIEW_NAME;
commit;
column owner format a10
column table_name format a15
column mview_name format a15
column detailobj_owner format a10 heading 'Detailobj|Owner'
column detailobj_name  format a15
column detailobj_alias format a20
column detail_partition_name format a20
column detail_subpartition_name format a20
column parent_table_partition format a20
SELECT MVIEW_NAME, STALENESS, LAST_REFRESH_TYPE, COMPILE_STATE FROM USER_MVIEWS ORDER BY MVIEW_NAME;
select * from user_mview_detail_relations;
select * from user_mview_detail_partition;
select * from user_mview_detail_subpartition where freshness != 'FRESH';

