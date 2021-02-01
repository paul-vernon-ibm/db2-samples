--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Reports of the progress of any background extent movement such as as initiated by ALTER TABLESPACE REDUE MAX
 */

CREATE OR REPLACE VIEW DB_TABLESPACE_REDUCE_PROGRESS AS
SELECT TBSP_NAME                                         AS TBSPACE
,      SUM(NUM_EXTENTS_MOVED)                            AS EXTENTS_MOVED
,      SUM(NUM_EXTENTS_LEFT)                             AS EXTENTS_LEFT
,      DEC(ROUND(MAX(TOTAL_MOVE_TIME)/1000/60.0,2),9,2)  AS DURATION_MINS
,      DECIMAL((SUM(NUM_EXTENTS_MOVED) / ((SUM(NUM_EXTENTS_MOVED) + SUM(NUM_EXTENTS_LEFT)) *1.0))*100,5,2) AS PCT_COMPLETE
,      DEC(SUM(TOTAL_MOVE_TIME) * 1.0/SUM(NUM_EXTENTS_MOVED),6,1)                                   AS EXTENTS_PER_SEC
--,      TIMESTAMP(CURRENT TIMESTAMP,0) + ((SUM(TOTAL_MOVE_TIME)*1000.0/SUM(NUM_EXTENTS_MOVED))*SUM(NUM_EXTENTS_LEFT)) SECONDS  AS EST_FINISH_DT
FROM
       TABLE( MON_GET_EXTENT_MOVEMENT_STATUS(NULL,-2)) 
WHERE
       TOTAL_MOVE_TIME > 0
GROUP BY
      TBSP_NAME