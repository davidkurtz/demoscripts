REM ledger3.sql
spool ledger3
@@preledger.sql

CREATE TABLE ps_ledger
(business_unit VARCHAR2(5) NOT NULL
,ledger VARCHAR2(10) NOT NULL
,account VARCHAR2(10) NOT NULL
,altacct VARCHAR2(10) NOT NULL
,deptid VARCHAR2(10) NOT NULL
,operating_unit VARCHAR2(8) NOT NULL
,product VARCHAR2(6) NOT NULL
,fund_code VARCHAR2(5) NOT NULL
,class_fld VARCHAR2(5) NOT NULL
,program_code VARCHAR2(5) NOT NULL
,budget_ref VARCHAR2(8) NOT NULL
,affiliate VARCHAR2(5) NOT NULL
,affiliate_intra1 VARCHAR2(10) NOT NULL
,affiliate_intra2 VARCHAR2(10) NOT NULL
,chartfield1 VARCHAR2(10) NOT NULL
,chartfield2 VARCHAR2(10) NOT NULL
,chartfield3 VARCHAR2(10) NOT NULL
,project_id VARCHAR2(15) NOT NULL
,book_code VARCHAR2(4) NOT NULL
,gl_adjust_type VARCHAR2(4) NOT NULL
,currency_cd VARCHAR2(3) NOT NULL
,statistics_code VARCHAR2(3) NOT NULL
,fiscal_year SMALLINT NOT NULL
,accounting_period SMALLINT NOT NULL
,posted_total_amt DECIMAL(26,3) NOT NULL
,posted_base_amt DECIMAL(26,3) NOT NULL
,posted_tran_amt DECIMAL(26,3) NOT NULL
,base_currency VARCHAR2(3) NOT NULL
,dttm_stamp_sec TIMESTAMP
,process_instance DECIMAL(10) NOT NULL
) PCTFREE 10 PCTUSED 80
PARTITION BY RANGE (FISCAL_YEAR) INTERVAL (1)
(PARTITION ledger_2018 VALUES LESS THAN (2019) PCTFREE 0 COMPRESS
,PARTITION ledger_2019 VALUES LESS THAN (2020) PCTFREE 0 COMPRESS)
ENABLE ROW MOVEMENT NOLOGGING
/
@treeselectors
@popledger

/*CREATE MATERIALIZED VIEW mv_ledger_2019
PARTITION BY RANGE (FISCAL_YEAR)
(PARTITION ledger_2019 VALUES LESS THAN (2020) 
,PARTITION ledger_2020 VALUES LESS THAN (2021) 
) PCTFREE 0 COMPRESS
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT business_unit, account, chartfield1, fiscal_year, accounting_period,
sum(posted_total_amt) posted_total_amt
FROM ps_ledger
WHERE fiscal_year = 2019
AND   ledger = 'ACTUALS'
AND   currency_cd = 'GBP'
GROUP BY business_unit, account, chartfield1, fiscal_year, accounting_period
*/

CREATE MATERIALIZED VIEW mv_ledger_2020
PARTITION BY RANGE (FISCAL_YEAR) INTERVAL (1)
(PARTITION ledger_2019 VALUES LESS THAN (2020)
) PCTFREE 0 COMPRESS
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT business_unit, account, chartfield1, fiscal_year, accounting_period,
sum(posted_total_amt) posted_total_amt
FROM ps_ledger
WHERE fiscal_year >= 2019
AND   ledger = 'ACTUALS'
AND   currency_cd = 'GBP'
GROUP BY business_unit, account, chartfield1, fiscal_year, accounting_period
/

@@mvpop
@@mvvol
@@mvsql

@@pop2020m7
@@mvsql

@@mvtrc
@@mvvol
@@mvsql
@@mvcap
SPOOL OFF

