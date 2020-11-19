REM preledger.sql
clear screen 
connect scott/tiger@oracle_pdb
set time on timi on autotrace off pages 99 lines 200 trimspool on echo on
alter session set nls_date_Format = 'hh24:mi:ss dd/mm/yyyy';
drop table ps_ledger purge;
drop materialized view mv_ledger_2019;
drop table mv_ledger_2019 purge;
drop materialized view mv_ledger_2020;
drop table mv_ledger_2020 purge;
DROP TABLE PSTREESELECT05 PURGE;
DROP TABLE PSTREESELECT10 PURGE;
purge recyclebin;
