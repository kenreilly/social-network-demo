CREATE TYPE public.image_format AS ENUM ( 'JPG', 'PNG', 'GIF' );

CREATE TYPE public.new_image AS (
	user_id uuid,
	format image_format,
	is_profile boolean
);

CREATE TABLE public.images (
	id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
	user_id uuid NOT NULL,
	format image_format,
	is_profile boolean DEFAULT false NOT NULL,
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
		if img.is_profile = true then
			update images set is_profile = false where user_id = img.user_id;
		end if;
		insert into images (user_id, format, is_profile)
			values (img.user_id, img.format, img.is_profile) returning id into _id;
		return _id;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.add_image(img new_image)  OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.add_image(img new_image) TO social_demo_api_role;

CREATE FUNCTION public.delete_image(image_id uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		DELETE FROM images WHERE id = image_id;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.delete_image(image_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.delete_image(image_id uuid) TO social_demo_api_role;
