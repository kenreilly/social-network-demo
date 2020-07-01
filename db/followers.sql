CREATE TABLE public.followers (
	user_id uuid REFERENCES users,
	follower_id uuid REFERENCES users,
	PRIMARY KEY (user_id, follower_id),
	create_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.followers OWNER to social_demo_admin;
GRANT SELECT ON TABLE users TO social_demo_api_role;

CREATE FUNCTION public.add_follower(user_id uuid, follower_id uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		insert into followers (user_id, follower_id) values (user_id, follower_id);
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.add_follower(user_id uuid, follower_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.add_follower(user_id uuid, follower_id uuid) TO social_demo_api_role;

CREATE FUNCTION public.remove_follower(user_id uuid, follower_id uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		DELETE FROM followers WHERE user_id = user_id AND follower_id = follower_id;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.remove_follower(user_id uuid, follower_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.remove_follower(user_id uuid, follower_id uuid) TO social_demo_api_role;

CREATE FUNCTION public.get_followers(user_id uuid) RETURNS uuid[]
	LANGUAGE plpgsql
	AS $_$
	DECLARE
		followers uuid[];
	BEGIN
		select follower_id from followers where user_id = user_id into followers;
		return followers;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.get_followers(user_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.get_followers(user_id uuid) TO social_demo_api_role;
