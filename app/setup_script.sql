CREATE APPLICATION ROLE IF NOT EXISTS app_user;
CREATE APPLICATION ROLE IF NOT EXISTS app_admin;

CREATE SCHEMA IF NOT EXISTS core;
GRANT USAGE ON SCHEMA core TO APPLICATION ROLE app_user;

CREATE OR ALTER VERSIONED SCHEMA app_public;
GRANT USAGE ON SCHEMA app_public TO APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE core.grant_callback(priv array)
RETURNS STRING
LANGUAGE SQL
AS
$$ 
   CALL app_public.start_app(); 
$$;

GRANT USAGE ON PROCEDURE core.grant_callback(array) to APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE app_public.start_app()
   RETURNS string
   LANGUAGE sql
   AS
$$
BEGIN
   LET pool_name := (SELECT CURRENT_DATABASE()) || '_compute_pool';

   CREATE COMPUTE POOL IF NOT EXISTS IDENTIFIER(:pool_name)
      MIN_NODES = 1
      MAX_NODES = 1
      INSTANCE_FAMILY = CPU_X64_XS
      AUTO_RESUME = true;

   CREATE SERVICE IF NOT EXISTS core.mongo_service
      IN COMPUTE POOL identifier(:pool_name)
      FROM spec='service/mongo.yaml';

   GRANT SERVICE ROLE core.mongo_service!ALL_ENDPOINTS_USAGE TO APPLICATION ROLE app_user;   

   RETURN 'Service successfully created';
END;
$$;

GRANT USAGE ON PROCEDURE app_public.start_app() TO APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE app_public.service_status()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS $$
   DECLARE
         service_status VARCHAR;
   BEGIN
         CALL SYSTEM$GET_SERVICE_STATUS('core.mongo_service') INTO :service_status;
         RETURN PARSE_JSON(:service_status)[0]['status']::VARCHAR;
   END;
$$;

GRANT USAGE ON PROCEDURE app_public.service_status() TO APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE app_public.service_logs_front()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS $$
   DECLARE
         service_logs VARCHAR;
   BEGIN
         CALL SYSTEM$GET_SERVICE_LOGS('core.mongo_service', 0, 'mongofront') INTO :service_logs;
         RETURN service_logs;
   END;
$$;

GRANT USAGE ON PROCEDURE app_public.service_logs_front() TO APPLICATION ROLE app_user;



CREATE OR REPLACE PROCEDURE app_public.showcontainers()
RETURNS VARCHAR
LANGUAGE PYTHON
PACKAGES = ('snowflake-snowpark-python')
RUNTIME_VERSION = 3.9
HANDLER = 'main'
as
$$
def main(session):
    return session.sql(f"""
    SHOW SERVICE CONTAINERS IN SERVICE core.mongo_service
    """).collect()
$$;

GRANT USAGE ON PROCEDURE app_public.showcontainers() TO APPLICATION ROLE app_user;
CREATE OR REPLACE PROCEDURE app_public.service_logs_db()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS $$
   DECLARE
         service_logs VARCHAR;
   BEGIN
         CALL SYSTEM$GET_SERVICE_LOGS('core.mongo_service', 0, 'mongo') INTO :service_logs;
         RETURN service_logs;
   END;
$$;

GRANT USAGE ON PROCEDURE app_public.service_logs_db() TO APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE app_public.getEndpoints(service_name varchar)
RETURNS VARCHAR
LANGUAGE PYTHON
PACKAGES = ('snowflake-snowpark-python')
RUNTIME_VERSION = 3.9
HANDLER = 'main'
as
$$
def main(session, service_name):
    return session.sql(f"""
    SHOW ENDPOINTS IN SERVICE core.{service_name}
    """).collect()
$$;

GRANT USAGE ON PROCEDURE app_public.getEndpoints(varchar) TO APPLICATION ROLE app_user;
