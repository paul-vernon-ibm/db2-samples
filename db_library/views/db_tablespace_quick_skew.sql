--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows any data skew at the tablespace level. Only shows data for tablespaces touched since the last Db2 restart
 */

CREATE OR REPLACE VIEW DB_TABLESPACE_QUICK_SKEW AS
SELECT 
    TBSP_NAME    
,   MAX(TBSP_PAGE_TOP) * MAX(TBSP_PAGE_SIZE) / 1048576  AS MAX_TOP_MB
,   MIN(TBSP_PAGE_TOP) * MAX(TBSP_PAGE_SIZE) / 1048576  AS MIN_TOP_MB
,   DECIMAL( (MAX(TBSP_USED_PAGES) - AVG(TBSP_USED_PAGES)) * COUNT(*) * MAX(TBSP_PAGE_SIZE) / POWER(1024.0,3),17,3) AS WASTED_GB
,   DECIMAL((1 - AVG(TBSP_PAGE_TOP*1.0)/ NULLIF(MAX(TBSP_PAGE_TOP),0))*100,5,2)    AS SKEW
,   MAX(CASE WHEN MEMBER_ASC_RANK = 1  THEN MEMBER END) AS SMALLEST_MEMBER
,   MAX(CASE WHEN MEMBER_DESC_RANK = 1 THEN MEMBER END) AS LARGEST_MEMBER
FROM
    (SELECT T.*
    ,       ROW_NUMBER() OVER (PARTITION BY TBSP_NAME ORDER BY TBSP_USED_PAGES ASC)  AS MEMBER_ASC_RANK
    ,       ROW_NUMBER() OVER (PARTITION BY TBSP_NAME ORDER BY TBSP_USED_PAGES DESC) AS MEMBER_DESC_RANK
    FROM
     TABLE(MON_GET_TABLESPACE(NULL,-2)) T
     ) T
GROUP BY 
    TBSP_NAME
HAVING COUNT(*) > 1