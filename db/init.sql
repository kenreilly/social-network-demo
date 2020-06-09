REVOKE ALL ON SCHEMA PUBLIC FROM social_demo_api_role;
DROP DATABASE IF EXISTS social_demo;
DROP USER IF EXISTS social_demo_admin;
DROP USER IF EXISTS social_demo_api;
DROP ROLE IF EXISTS social_demo_api_role;
CREATE USER social_demo_admin WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'insecure_password';
CREATE USER social_demo_api WITH LOGIN PASSWORD 'insecure_password';
CREATE DATABASE social_demo WITH OWNER = social_demo_admin ENCODING = 'UTF8' CONNECTION LIMIT = -1;
CREATE ROLE social_demo_api_role;
GRANT CONNECT ON DATABASE social_demo TO social_demo_api_role;
GRANT USAGE ON SCHEMA PUBLIC TO social_demo_api_role;
GRANT social_demo_api_role to social_demo_api