REM dup_sql_profiles1.sql
set long 600 lines 200 pages 999
break on force_sig skip 1
column profile# heading 'Prof|#' format 999
column num_profiles heading 'Num|Profs' format 999
column exact_sig heading 'Exact Matching|Signature' format 99999999999999999999
column force_sig heading 'Force Matching|Signature' format 99999999999999999999
column name format a30
column category format a20
column created format a28
column sql_Text format a200 wrap on
--column exact_name heading 'Exact|Name' format a30
--column force_name heading 'Force|Name' format a30
--column exact_created heading 'Exact|Created Date' format a28
--column force_created heading 'Force|Created Date' format a28
--column exact_status heading 'Exact|Status'
--column force_status heading 'Force|Status'
--column common_text heading 'Common Text' format a199
--column ediff_text heading 'Exact Text' format a99
--column fdiff_text heading 'Force Text' format a99
alter session set nls_timestamp_format = 'hh24:mi:ss dd/mm/yyyy';
spool dup_sql_profiles1
WITH function sig(p_sql_text CLOB, p_number INTEGER) RETURN NUMBER IS
 l_sig NUMBER;
BEGIN
 IF p_number > 0 THEN 
  l_sig := dbms_sqltune.sqltext_to_signature(p_sql_text,TRUE);
 ELSIF p_number = 0 THEN 
  l_sig := dbms_sqltune.sqltext_to_signature(p_sql_text,FALSE);
 END IF;
 RETURN l_sig;
END;
x as (
select CASE WHEN force_matching = 'NO'  THEN signature ELSE NULL /*sig(sql_text, 0)*/ END exact_sig
,      CASE WHEN force_matching = 'YES' THEN signature ELSE sig(sql_text, 1) END force_sig
,      p.*
from   dba_sql_profiles p
where  (status = 'ENABLED' or force_matching = 'NO')
and    category = 'DEFAULT'
), y as (
select x.*
, row_number() over (partition by category, force_sig order by force_matching desc, exact_sig nulls first) profile#
, count(*) over (partition by category, force_sig) num_profiles
from x
)
select profile#, num_profiles, force_sig, exact_sig, name, created, category, status, force_matching, sql_text
from y
where num_profiles > 1
--and force_matching = 'NO'
--and force_sig = 13263870199881122078
order by force_sig, force_matching desc, exact_sig
/
spool off