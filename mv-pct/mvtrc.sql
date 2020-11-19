REM mvtrc.sql
disconnect
connect scott/tiger@oracle_pdb
alter session set nls_date_Format = 'hh24:mi:ss dd/mm/yyyy';

column name format a20
column value format a70
select * from v$diag_info where name like '%Trace%';

alter session set tracefile_identifier=PCT;
alter session set sql_trace = true;
exec dbms_mview.refresh(list=>'MV_LEDGER_2019',method=>'P',atomic_refresh=>FALSE);
exec dbms_mview.refresh(list=>'MV_LEDGER_2020',method=>'P',atomic_refresh=>FALSE);
alter session set sql_trace = false;

exec dbms_mview.refresh(list=>'MV_LEDGER_2019',method=>'P',atomic_refresh=>FALSE);
exec dbms_mview.refresh(list=>'MV_LEDGER_2020',method=>'P',atomic_refresh=>FALSE);

exec dbms_stats.gather_Table_stats(user,'MV_LEDGER_2019');
exec dbms_stats.gather_Table_stats(user,'MV_LEDGER_2020');

