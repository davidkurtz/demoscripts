REM dup_sql_profiles2.sql
set long 5000 serveroutput on lines 200 pages 999
break on force_sig skip 1
alter session set nls_timestamp_format = 'hh24:mi:ss dd/mm/yyyy';
--column name format a30
--column category format a20
--column created format a28
--column profile# heading 'Prof#' format 9999
--column num_profiles heading 'Num|SQL|Profs' format 9999
--column sql_Text format a200 wrap on
column exact_sig heading 'Exact Matching|Signature' format 99999999999999999999
column force_sig heading 'Force Matching|Signature' format 99999999999999999999
column exact_name heading 'Exact|Name' format a30
column force_name heading 'Force|Name' format a30
column exact_created heading 'Exact|Created Date' format a28
column force_created heading 'Force|Created Date' format a28
column exact_status heading 'Exact|Status'
column force_status heading 'Force|Status'
column common_text heading 'Common Text' format a199
column ediff_text heading 'Exact Text' format a99
column fdiff_text heading 'Force Text' format a99
break on force_sig skip 1 on force_name on force_matching on force_created 
spool dup_sql_profiles2
WITH function sig(p_sql_text CLOB, p_number INTEGER) RETURN NUMBER IS
 l_sig NUMBER;
BEGIN
 IF p_number > 0 THEN 
  l_sig := dbms_sqltune.sqltext_to_signature(p_sql_text,TRUE);
 ELSIF p_number = 0 THEN 
  l_sig := dbms_sqltune.sqltext_to_signature(p_sql_text,FALSE);
 END IF;
 RETURN l_sig;
END sig;
function norm(p_queryin CLOB) RETURN CLOB IS
  l_queryin CLOB;
  l_queryout CLOB;
  l_lastchar varchar2(1) := ' '; 
  l_char varchar2(1);
  l_in_quotes boolean default FALSE;
begin
  l_queryin := p_queryin;
  l_queryin := REGEXP_REPLACE(l_queryin, '[^[:print:]]', ' ');
--l_queryin := REGEXP_REPLACE(l_queryin, '(\r\n)+|\r+|\n+|\t+', ' ');
  for i in 1 .. length( l_queryin )
   loop
     l_char := substr(l_queryin,i,1);
     if ( l_char = '''' and l_in_quotes )
      then
       l_in_quotes := FALSE;
     elsif ( l_char = '''' and NOT l_in_quotes )
      then
       l_in_quotes := TRUE;
     end if;

    if ( l_in_quotes ) 
      then
       l_queryout := l_queryout || l_char;
    elsif ( NOT l_in_quotes and l_char = ' ' and l_lastchar = ' ') THEN
	--elsif ( NOT l_in_quotes and REGEXP_LIKE(l_char,'[[:space:]]') and REGEXP_LIKE(l_lastchar,'[[:space:]]')) THEN
       NULL;
    else 
       l_queryout := l_queryout || upper(l_char);
    end if;
    l_lastchar := l_char;
  end loop;
  RETURN l_queryout;
END norm;
function str_diff(p_str1 CLOB, p_str2 CLOB) RETURN NUMBER IS
  l_len1 INTEGER;
  l_len2 INTEGER;
  l_counter INTEGER := 1;
BEGIN
  l_len1 := LENGTH(p_str1);
  l_len2 := LENGTH(p_str2);
  WHILE l_counter <= l_len1 AND l_counter <= l_len2 LOOP
--  dbms_output.put_line(l_counter||':'||substr(p_str1,l_counter,1)||'='||substr(p_str2,l_counter,1));
    IF substr(p_str1,l_counter,1) = substr(p_str2,l_counter,1) THEN
      l_counter := l_counter + 1;
    ELSE
      RETURN l_counter-1;
    END IF;
  END LOOP;
  RETURN 0;
END str_diff;
x as (
select CASE WHEN force_matching = 'NO'  THEN signature ELSE sig(sql_text, 0) END exact_sig
,      CASE WHEN force_matching = 'YES' THEN signature ELSE sig(sql_text, 1) END force_sig
,      p.*
--,      h.comp_data
--,      ora_hash(h.comp_data) hint_hash
from   dba_sql_profiles p
--,      DBMSHSXP_SQL_PROFILE_ATTR h
--WHERE  p.name = h.profile_name
), y as (
select f.force_matching, f.force_sig, f.name force_name, f.created force_created, f.status force_status
,      e.force_matching exact_matching, e.exact_sig, e.name exact_name, e.created exact_created, e.status exact_status, e.category
--,      e.hint_hash, f.hint_hash
,      norm(e.sql_text) esql_text, norm(f.sql_text) fsql_text
from   x e
,      x f
where  f.force_matching = 'YES'
and    e.force_matching = 'NO'
and    e.force_sig = f.force_sig
and    e.category = f.category
and    e.name != f.name
and    f.status = 'ENABLED'
--and    e.status = 'ENABLED'
), z as (
select y.*
,      str_diff(fsql_Text, esql_text) diff_len
from y
)
select force_matching, force_Sig, force_name, force_created, force_status
,      exact_matching, exact_sig, exact_name, exact_Created, exact_status
, substr(fsql_text,1,diff_len) common_text
, substr(fsql_text,diff_len+1) fdiff_text
, substr(esql_text,diff_len+1) ediff_text
from z
--where force_sig = 13263870199881122078
order by force_sig
--fetch first 1 rows only
/
spool off


