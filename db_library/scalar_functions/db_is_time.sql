--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Returns 1 if the input string can be CAST to a TIME, else returns 0 Returns 1 is the input string can be CAST to a TIMESTAMP, else returns 0
 */

CREATE OR REPLACE FUNCTION DB_IS_TIME(i VARCHAR(64)) RETURNS INTEGER
    CONTAINS SQL ALLOW PARALLEL 
    NO EXTERNAL ACTION
    DETERMINISTIC
BEGIN 
  DECLARE NOT_VALID CONDITION FOR SQLSTATE '22007';
  DECLARE EXIT HANDLER FOR NOT_VALID RETURN 0;
  
  RETURN CASE WHEN CAST(i AS TIME) IS NOT NULL THEN 1 END;
END