CREATE TYPE new_post AS (
	user_id uuid,
	image_id uuid,
	content character varying(2048)
);

CREATE TABLE public.posts (
	id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
	user_id uuid REFERENCES users,
	image_id uuid REFERENCES images NULL,
	content character varying(2048) COLLATE pg_catalog."default",
	create_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.posts OWNER to social_demo_admin;
GRANT SELECT ON TABLE public.posts TO social_demo_api_role;

CREATE FUNCTION public.create_post(post new_post) RETURNS uuid
	LANGUAGE plpgsql
	AS $_$
	DECLARE
		_id uuid;
	BEGIN
		insert into posts (user_id, image_id, content)
		values (post.user_id, post.image_id, post.content) returning id into _id;
		return _id;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.create_post(post new_post) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.create_post(post new_post) TO social_demo_api_role;

CREATE FUNCTION public.delete_post(post_id uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	DECLARE
		_id boolean;
	BEGIN
		DELETE FROM posts WHERE id = post_id;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.delete_post(post_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.delete_post(post_id uuid) TO social_demo_api_role;
