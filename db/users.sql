CREATE TYPE public.authenticated_user AS (
	id uuid,
	first_name character varying,
	last_name character varying,
	auth_timestamp timestamp without time zone
);

CREATE TYPE public.new_user AS (
	email character varying,
	password_text character varying,
	first_name character varying,
	last_name character varying
);

ALTER TYPE public.authenticated_user OWNER TO social_demo_admin;

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
    email character varying UNIQUE NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    password_hash character varying NOT NULL,
    create_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.users OWNER TO social_demo_admin;
GRANT SELECT ON TABLE public.users TO social_demo_api_role;

CREATE FUNCTION public.authenticate_user(email text, password_text text) RETURNS public.authenticated_user
    LANGUAGE plpgsql
    AS $_$
DECLARE
	user authenticated_user;
BEGIN
	select into user.id, user.first_name, user.last_name, user.auth_timestamp 
		id, first_name, last_name, current_timestamp from users 
		where users.email = $1
		and users.password_hash = crypt($2, password_hash);
	return user;
END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.authenticate_user(email text, password_text text) OWNER TO social_demo_admin;

CREATE FUNCTION public.create_user(usr new_user) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
	user_id text;
BEGIN
	insert into public.users (email, password_hash, first_name, last_name) 
	values (usr.email, hash(usr.password_text), usr.first_name, usr.last_name) returning id into user_id;
	return user_id;
END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.create_user(usr new_user) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.create_user(usr new_user) TO social_demo_api_role;
