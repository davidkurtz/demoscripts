REM popledger.sql
set autotrace off echo on pages 99 lines 200 trimspool on

truncate table ps_ledger;
exec dbms_stats.set_table_prefs('SCOTT','PS_LEDGER','METHOD_OPT','FOR ALL COLUMNS SIZE 1, FOR COLUMNS FISCAL_YEAR, ACCOUNTING_PERIOD, LEDGER, BUSINESS_UNIT SIZE 254');
exec dbms_stats.set_table_prefs('SCOTT','PS_LEDGER','GRANULARITY','ALL');

ALTER TABLE PS_LEDGER PARALLEL 8 NOLOGGING;

CREATE UNIQUE INDEX ps_ledger ON ps_ledger
(business_unit,ledger,account,altacct,deptid
,operating_unit,product,fund_code,class_fld,program_code
,budget_ref,affiliate,affiliate_intra1,affiliate_intra2,chartfield1
,chartfield2,chartfield3,project_id,book_code,gl_adjust_type
/*,date_code*/,currency_cd,statistics_code,fiscal_year,accounting_period
) COMPRESS 2 NOPARALLEL
/

insert /*+APPEND PARALLEL ENABLE_PARALLEL_DML NO_GATHER_OPTIMIZER_STATISTICS ignore_row_on_dupkey_index(l)*/ into ps_ledger l
with n as (
SELECT rownum n from dual connect by level <= 1e2
), fy as (
SELECT /*+MATERIALIZE*/ 2017+rownum fiscal_year FROM dual CONNECT BY level <= 4
), ap as (
SELECT /*+MATERIALIZE*/ FLOOR(dbms_random.value(0,13)) accounting_period FROM dual connect by level <= 998
UNION ALL SELECT 998 FROM DUAL CONNECT BY LEVEL <= 1
UNION ALL SELECT 999 FROM DUAL CONNECT BY LEVEL <= 1
), l as (
SELECT /*+MATERIALIZE*/ 'ACTUALS' ledger FROM DUAL CONNECT BY LEVEL <= 10
UNION ALL SELECT 'BUDGET' FROM DUAL
)
select 'BU'||LTRIM(TO_CHAR(CASE WHEN dbms_random.value <= .9 THEN 1 ELSE 2 END,'000')) business_unit 
,      l.ledger
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
,      fy.fiscal_year
,      ap.accounting_period
,      dbms_random.value(0,1e6) posted_total_amt 
,      0 posted_base_amt 
,      0 posted_tran_amt 
,      'GBP' base_currency 
,      SYSDATE dttm_stamp_sec
,      0 process_instance 
FROM   fy,ap, l, n
WHERE  l.ledger = 'BUDGET' or (fy.fiscal_year < 2020 or (fy.fiscal_year = 2020 AND ap.accounting_period <= 6))
/
commit;
exec dbms_stats.gather_table_stats('SCOTT','PS_LEDGER');

CREATE /*UNIQUE*/ INDEX ps_ledger ON ps_ledger
(business_unit,ledger,account,altacct,deptid
,operating_unit,product,fund_code,class_fld,program_code
,budget_ref,affiliate,affiliate_intra1,affiliate_intra2,chartfield1
,chartfield2,chartfield3,project_id,book_code,gl_adjust_type
/*,date_code*/,currency_cd,statistics_code,fiscal_year,accounting_period
) COMPRESS 2 NOPARALLEL NOLOGGING
/

CREATE INDEX psxledger ON ps_ledger
(ledger, fiscal_year, accounting_period, business_unit, account, chartfield1
) LOCAL COMPRESS 4 PARALLEL NOLOGGING
/

CREATE INDEX psyledger ON ps_ledger
(ledger, fiscal_year, business_unit, account, chartfield1, accounting_period
) LOCAL COMPRESS 3 PARALLEL NOLOGGING
/

ALTER INDEX ps_ledger NOPARALLEL;
ALTER INDEX psxledger NOPARALLEL;
ALTER INDEX psyledger NOPARALLEL;

break on report on ledger skip 1
compute sum of count(*) on report 
set autotrace off
select ledger, fiscal_year, count(*), max(accounting_period)
from ps_ledger
group by ledger, fiscal_year
order by 1,2
/
compute sum of count(*) on fiscal_year
break on report on fiscal_year skip 1 on ledger skip 1
select ledger, fiscal_year, accounting_period, count(*)
from ps_ledger
group by ledger, fiscal_year, accounting_period
order by 1,2,3
/
break on ledger skip 1 on fiscal_year skip 1
select ledger, account, count(*)
from ps_ledger
where 1=2
group by ledger, account
order by 1,3
/

TRUNCATE TABLE PSTREESELECT05;
TRUNCATE TABLE PSTREESELECT10;

INSERT INTO PSTREESELECT05
WITH x as (SELECT DISTINCT business_unit FROM ps_ledger)
, y as (SELECT 30982, FLOOR(DBMS_RANDOM.value(1,1e10)) tree_node_num, business_unit FROM x)
select y.*, business_unit FROM y
/
INSERT INTO PSTREESELECT10
WITH x as (SELECT DISTINCT account FROM ps_ledger)
, y as (SELECT 30984, FLOOR(DBMS_RANDOM.value(1,1e10)) tree_node_num, account FROM x)
select y.*, account FROM y
where mod(tree_node_num,100)<25
/
INSERT INTO PSTREESELECT10
WITH x as (SELECT DISTINCT chartfield1 FROM ps_ledger)
, y as (SELECT 30985, FLOOR(DBMS_RANDOM.value(1,1e10)) tree_node_num, chartfield1 FROM x)
select y.*, chartfield1 FROM y
where mod(tree_node_num,100)<10
/
commit;

exec dbms_stats.gather_table_stats('SCOTT','PSTREESELECT05');
exec dbms_stats.gather_table_stats('SCOTT','PSTREESELECT10');

ALTER TABLE PS_LEDGER NOPARALLEL;

/*explain plan for 
SELECT L.TREE_NODE_NUM,L2.TREE_NODE_NUM,SUM(A.POSTED_TOTAL_AMT)
FROM   PS_LEDGER A
,      PSTREESELECT05 L1
,      PSTREESELECT10 L
,      PSTREESELECT10 L2
WHERE  A.LEDGER='ACTUALS'
AND    A.FISCAL_YEAR=2020
AND    A.ACCOUNTING_PERIOD BETWEEN 1 AND 2
AND    L1.SELECTOR_NUM=30982 AND A.BUSINESS_UNIT=L1.RANGE_FROM_05
AND    L.SELECTOR_NUM=30985 AND A.CHARTFIELD1=L.RANGE_FROM_10
AND    L2.SELECTOR_NUM=30984 AND A.ACCOUNT=L2.RANGE_FROM_10
AND    A.CURRENCY_CD='GBP'
GROUP BY L.TREE_NODE_NUM,L2.TREE_NODE_NUM
/
@@xp*/