-- Create databases for all 4 microservices (matches k8s/postgres init ConfigMap)
CREATE DATABASE user_db;
CREATE DATABASE job_db;
CREATE DATABASE application_db;
CREATE DATABASE notification_db;

GRANT ALL PRIVILEGES ON DATABASE user_db TO jobportal;
GRANT ALL PRIVILEGES ON DATABASE job_db TO jobportal;
GRANT ALL PRIVILEGES ON DATABASE application_db TO jobportal;
GRANT ALL PRIVILEGES ON DATABASE notification_db TO jobportal;
