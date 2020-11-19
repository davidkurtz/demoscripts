REM mvpop.sql
set autotrace off
break on table_name skip 1 on partition_name
column table_name format a15
column index_name format a25
column mview_name format a15
SELECT MVIEW_NAME, STALENESS, LAST_REFRESH_TYPE, COMPILE_STATE FROM USER_MVIEWS ORDER BY MVIEW_NAME;

--exec dbms_mview.refresh(list=>'MV_LEDGER_2019',method=>'P',atomic_refresh=>FALSE);
--exec dbms_mview.refresh(list=>'MV_LEDGER_2020',method=>'P',atomic_refresh=>FALSE);

--exec dbms_mview.refresh(list=>'MV_LEDGER_2019',method=>'C',atomic_refresh=>FALSE);
--exec dbms_mview.refresh(list=>'MV_LEDGER_2020',method=>'C',atomic_refresh=>FALSE);

ALTER MATERIALIZED VIEW mv_ledger_2019 NOPARALLEL;
exec dbms_stats.set_table_prefs('SCOTT','MV_LEDGER_2019','METHOD_OPT','FOR ALL COLUMNS SIZE 1, FOR COLUMNS FISCAL_YEAR, ACCOUNTING_PERIOD, BUSINESS_UNIT SIZE 254');
exec dbms_stats.set_table_prefs('SCOTT','MV_LEDGER_2019','GRANULARITY','ALL');

ALTER MATERIALIZED VIEW mv_ledger_2020 NOPARALLEL;
exec dbms_stats.set_table_prefs('SCOTT','MV_LEDGER_2020','METHOD_OPT','FOR ALL COLUMNS SIZE 1, FOR COLUMNS FISCAL_YEAR, ACCOUNTING_PERIOD, BUSINESS_UNIT SIZE 254');
exec dbms_stats.set_table_prefs('SCOTT','MV_LEDGER_2020','GRANULARITY','ALL');

exec dbms_stats.gather_table_stats('SCOTT','MV_LEDGER_2019');
exec dbms_stats.gather_table_stats('SCOTT','MV_LEDGER_2020');
