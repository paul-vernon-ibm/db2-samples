--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Returns a count of activity by User and Workload
 */

CREATE OR REPLACE VIEW DB_USER_WORKLOADS AS
SELECT
    CASE WHEN SESSION_AUTH_ID <> SYSTEM_AUTH_ID THEN SESSION_AUTH_ID || '(' || SYSTEM_AUTH_ID || ')' 
        ELSE SYSTEM_AUTH_ID END AS USERID
,   CASE WHEN WORKLOAD_NAME IS NULL THEN 'NONE'
        WHEN WORKLOAD_NAME = 'SYSDEFAULTUSERWORKLOAD'   THEN 'DEFAULT USER' 
        WHEN WORKLOAD_NAME = 'SYSDEFAULTADMWORKLOAD'    THEN 'DEFAULT ADMIN'
        WHEN WORKLOAD_NAME = 'SYSDEFAULTSYSTEMWORKLOAD' THEN 'DEFAULT SYSTEM' 
        WHEN WORKLOAD_NAME = 'SYSDEFAULTMAINTWORKLOAD'  THEN 'DEFAULT MAINT' 
    ELSE WORKLOAD_NAME END AS WORKLOAD_NAME
,   CASE WHEN S.SERVICE_SUPERCLASS_NAME IS NULL THEN '' 
            WHEN S.SERVICE_SUPERCLASS_NAME IN ('SYSDEFAULTUSERCLASS','SYSDEFAULTSYSTEMCLASS') THEN 'DEFAULT' 
            ELSE S.SERVICE_SUPERCLASS_NAME END 
    || CASE WHEN S.SERVICE_SUBCLASS_NAME IN ('SYSDEFAULTSUBCLASS','SYSDEFAULTSYSTECLASS') THEN '' 
            ELSE CASE WHEN S.SERVICE_SUPERCLASS_NAME IS NOT NULL THEN '.' ELSE '' END 
                 || S.SERVICE_SUBCLASS_NAME END    
                          AS SERVICE_CLASS  
,   APPLICATION_NAME
,   CLIENT_USER
                          ,   WORKLOAD_OCCURRENCE_STATE   AS STATE
,   COUNT(DISTINCT APPLICATION_HANDLE)  AS CONNECTIONS
,   COUNT(DISTINCT UOW_ID)              AS UOWS
FROM
    TABLE(WLM_GET_SERVICE_CLASS_WORKLOAD_OCCURRENCES(default, default, -2)) S
GROUP BY
    SYSTEM_AUTH_ID
,   SESSION_AUTH_ID
,   APPLICATION_NAME
,   CLIENT_USER
,   WORKLOAD_NAME
,   SERVICE_SUPERCLASS_NAME
,   SERVICE_SUBCLASS_NAME
,   WORKLOAD_OCCURRENCE_STATE
