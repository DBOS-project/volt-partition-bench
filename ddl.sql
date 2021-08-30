-- These statements make this DDL idempotent (on an empty database)
DROP PROCEDURE Transfer1 IF EXISTS;
DROP PROCEDURE Transfer2 IF EXISTS;
DROP PROCEDURE Init IF EXISTS;
DROP TABLE accounts IF EXISTS;

-- This table holds a very small number of rows which are updated as often
-- as possible.
CREATE TABLE accounts (
  acc_id BIGINT NOT NULL,
  balance BIGINT NOT NULL
, PRIMARY KEY (acc_id)
);
PARTITION TABLE accounts ON COLUMN acc_id;

-- This statement adds a row with zero value for a given id, or leaves the value
-- intact if a row for that id was already present.
CREATE PROCEDURE Init PARTITION ON TABLE accounts COLUMN acc_id PARAMETER 0 AS 
	INSERT INTO accounts VALUES(?, 1000);

LOAD CLASSES account-transfer-proc.jar;

CREATE PROCEDURE FROM CLASS Transfer2; -- multi-partition transaction
CREATE PROCEDURE PARTITION ON TABLE accounts COLUMN acc_id FROM CLASS Transfer1; -- single-partition transaction
