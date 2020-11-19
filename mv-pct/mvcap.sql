REM mvcap.sql
REM spool mvcap
set autotrace off
create table MV_CAPABILITIES_TABLE
(
  statement_id      varchar(30) ,
  mvowner           varchar(30) ,
  mvname            varchar(30) ,
  capability_name   varchar(30) ,
  possible          character(1) ,
  related_text      varchar(2000) ,
  related_num       number ,
  msgno             integer ,
  msgtxt            varchar(2000) ,
  seq               number
) ;
 
truncate table MV_CAPABILITIES_TABLE;
EXECUTE DBMS_MVIEW.EXPLAIN_MVIEW ('SCOTT.MV_LEDGER_2019');
EXECUTE DBMS_MVIEW.EXPLAIN_MVIEW ('SCOTT.MV_LEDGER_2020');
break on mvname skip 1
column rel_text format a20
column msgtxt format a60
SELECT mvname, capability_name,  possible, SUBSTR(related_text,1,20) AS rel_text, SUBSTR(msgtxt,1,60) AS msgtxt
FROM MV_CAPABILITIES_TABLE
WHERE mvname like 'MV_LEDGER_20%'
ORDER BY mvname, seq;

REM spool off