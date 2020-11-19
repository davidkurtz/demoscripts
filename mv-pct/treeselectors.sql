REM treeselectors.sql 

DROP TABLE PSTREESELECT05 PURGE;
CREATE TABLE PSTREESELECT05
(SELECTOR_NUM INTEGER NOT NULL,
 TREE_NODE_NUM INTEGER NOT NULL,
 RANGE_FROM_05 VARCHAR2(05) NOT NULL,
 RANGE_TO_05   VARCHAR2(05) NOT NULL)
 PARTITION BY RANGE (SELECTOR_NUM) INTERVAL (1)
 (PARTITION pstreeselector VALUES LESS THAN (2))
 NOPARALLEL NOLOGGING;
CREATE UNIQUE INDEX PS_PSTREESELECT05 ON PSTREESELECT05 (SELECTOR_NUM, TREE_NODE_NUM, RANGE_FROM_05);

DROP TABLE PSTREESELECT10 PURGE;
CREATE TABLE PSTREESELECT10 
(SELECTOR_NUM INTEGER NOT NULL,
 TREE_NODE_NUM INTEGER NOT NULL,
 RANGE_FROM_10 VARCHAR2(10) NOT NULL,
 RANGE_TO_10   VARCHAR2(10) NOT NULL)
 PARTITION BY RANGE (SELECTOR_NUM) INTERVAL (1)
 (PARTITION pstreeselector VALUES LESS THAN (2))
 NOPARALLEL NOLOGGING;
CREATE UNIQUE INDEX PS_PSTREESELECT10 ON PSTREESELECT10 (SELECTOR_NUM, TREE_NODE_NUM, RANGE_FROM_10);

exec dbms_stats.set_table_prefs('SCOTT','PSTREESELECT05','GRANULARITY','ALL');
exec dbms_stats.set_table_prefs('SCOTT','PSTREESELECT10','GRANULARITY','ALL');
exec dbms_stats.set_table_prefs('SCOTT','PSTREESELECT05','METHOD_OPT','FOR ALL COLUMNS SIZE 1, FOR COLUMNS SELECTOR_NUM, (SELECTOR_NUM, TREE_NODE_NUM) SIZE 254');
exec dbms_stats.set_table_prefs('SCOTT','PSTREESELECT10','METHOD_OPT','FOR ALL COLUMNS SIZE 1, FOR COLUMNS SELECTOR_NUM, (SELECTOR_NUM, TREE_NODE_NUM) SIZE 254');

