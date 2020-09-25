CREATE TYPE image_format AS ENUM ( 'JPG', 'PNG', 'GIF' );

CREATE TYPE new_image AS (
	user_id uuid,
	format image_format,
	is_profile boolean,
	image_data bytea NOT NULL
);

CREATE TABLE public.images (
	id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
	user_id uuid NOT NULL,
	format image_format,
	is_profile boolean DEFAULT false NOT NULL,
	image_data bytea NOT NULL,
	create_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.images OWNER to social_demo_admin;
GRANT SELECT ON TABLE public.images TO social_demo_api_role;

CREATE FUNCTION public.add_image(img new_image) RETURNS uuid
	LANGUAGE plpgsql
	AS $_$
	DECLARE
		_id uuid;
	BEGIN
		insert into images (user_id, format, is_profile, image_data)
		values (img.user_id, img.format, img.is_profile, image_data) returning id into _id;
		return _id;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.add_image(img new_image)  OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.add_image(img new_image) TO social_demo_api_role;

CREATE FUNCTION public.delete_image(id uuid) RETURNS uuid
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		DELETE FROM images WHERE id = id;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.delete_image(id uuid)  OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.delete_image(id uuid) TO social_demo_api_role;
