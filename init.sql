USE ROLE ACCOUNTADMIN;

CREATE ROLE demo_role;

GRANT ROLE demo_role TO USER AALTEIRAC;

GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE demo_role;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE demo_role;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE demo_role;
GRANT CREATE APPLICATION PACKAGE ON ACCOUNT TO ROLE demo_role;
GRANT CREATE APPLICATION ON ACCOUNT TO ROLE demo_role;
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE demo_role WITH GRANT OPTION;
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE demo_role WITH GRANT OPTION;

USE ROLE demo_role;

CREATE OR REPLACE WAREHOUSE MONGO_WH WITH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 180
  AUTO_RESUME = true
  INITIALLY_SUSPENDED = false;

CREATE DATABASE MONGO_DB;
CREATE SCHEMA MONGO_SC;
CREATE IMAGE REPOSITORY MONGO_REPO; 




-- DOCKER STUFF

-- docker build --rm --platform linux/amd64 -t apiexposeimage:v0 .

-- REPO_URL=$(snow spcs image-repository url MONGO_DB.MONGO_SC.MONGO_REPO --role demo_role)
-- echo $REPO_URL

-- docker tag mongodb/mongodb-community-server $REPO_URL/mongodb:v0
-- docker tag mongo-express:<none> $REPO_URL/mongofront:v0

-- snow spcs image-registry login [-c connection_name]

-- docker push $REPO_URL/mongodb:v0
-- docker push $REPO_URL/mongofront:v0

-- snow spcs image-repository list-images MONGO_DB.MONGO_SC.MONGO_REPO --role demo_role