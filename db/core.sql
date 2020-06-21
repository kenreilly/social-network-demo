SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

CREATE FUNCTION public.hash(str text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
    BEGIN
        RETURN crypt($1, gen_salt('bf', 8));
    END;
$_$;

ALTER FUNCTION public.hash(str text) OWNER TO social_demo_admin;

CREATE FUNCTION public.flush() RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
    BEGIN
        DELETE FROM posts WHERE create_timestamp < current_timestamp - interval '1 day';
        DELETE FROM images WHERE is_profile = false AND create_timestamp < current_timestamp - interval '1 day';
        return true;
    END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.flush() OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.flush() TO social_demo_api_role;
