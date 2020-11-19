REM xp.sql
REM spool xp
REM set pages 9999 lines 200 autotrace off
select * from table(dbms_xplan.display(null,null,'ADVANCED -PROJECTION +ADAPTIVE'));
REM spool off
