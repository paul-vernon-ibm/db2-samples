--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows the COLCARD, FREQ_VALUEs and HIGH2KEY statistics stored for each column.
 */

CREATE OR REPLACE VIEW DB_COLUMN_STATS AS
SELECT  
    C.TABSCHEMA
,   C.TABNAME
,   C.COLNAME
,   C.COLNO
,   C.COLCARD
,   D.FREQ_VALUES
,   C.NUMNULLS
,   CASE WHEN C.TYPENAME IN ('VARCHAR','LONG VARCHAR','BLOB','CLOB','GRAPHIC','VARGRAPHIC','DBCLOB')
                THEN C.AVGCOLLEN ELSE NULL END      AVGLEN
,   C.LOW2KEY
,   C.HIGH2KEY
,   HIGH2VALUE
--,   TYPE_MAX
,   CASE WHEN HIGH2VALUE > 0 THEN QUANTIZE(HIGH2VALUE / TYPE_MAX, 0.0001) END  AS PCT_OF_MAX
FROM
(   SELECT *
    ,   CASE TYPENAME 
            WHEN 'SMALLINT' THEN 32767
            WHEN 'INTEGER'  THEN 2147483647
            WHEN 'BIGINT'   THEN 9223372036854775807
            WHEN 'DECIMAL'  THEN POWER(10::DECFLOAT,LENGTH - SCALE) -1  END AS TYPE_MAX
    ,   CASE WHEN TYPENAME IN ('BIGINT','INTEGER','SMALLINT','DECIMAL','DOUBLE','REAL','DECFLOAT')
              AND HIGH2KEY IS NOT NULL 
              AND HIGH2KEY <> ''
              AND SUBSTR(HIGH2KEY,1,1) <> x'00'
             THEN DECFLOAT(HIGH2KEY) END AS HIGH2VALUE
    FROM 
        SYSCAT.COLUMNS
) C
LEFT JOIN
(
    SELECT
        D.TABSCHEMA
    ,   D.TABNAME
    ,   D.COLNAME
--    ,   STDDEV(CASE WHEN D.TYPE = 'Q' THEN D.VALCOUNT END ) AS QUARTILE_STDDEV
    ,   LISTAGG(RTRIM(D.COLVALUE) || '(' || (DECIMAL((D.VALCOUNT * 100.00) /NULLIF(T.CARD,0),5,2)) || '%)', ',')
                WITHIN GROUP (ORDER BY D.SEQNO ) AS FREQ_VALUES
    FROM
        SYSCAT.COLDIST D
    INNER JOIN
        SYSCAT.TABLES T
    ON  
        D.TABSCHEMA = T.TABSCHEMA 
    AND D.TABNAME   = T.TABNAME
    WHERE
        D.TYPE = 'F'
    AND D.VALCOUNT > -1
    GROUP BY
        D.TABSCHEMA
    ,   D.TABNAME
    ,   D.COLNAME
)   D 
ON  
    C.TABSCHEMA = D.TABSCHEMA 
AND C.TABNAME   = D.TABNAME
AND C.COLNAME   = D.COLNAME
