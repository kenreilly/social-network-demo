CREATE TYPE new_room AS (
	owner_id uuid,
	image_id uuid,
	title character varying(32),
	about character varying(1024)
);

CREATE TABLE public.rooms (
	id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
	owner_id uuid references users not null,
	image_id uuid references images NULL,
	title character varying(2048) COLLATE pg_catalog."default" unique,
	about character varying(1024) COLLATE pg_catalog."default",
	create_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.room_users (
	room_id uuid references rooms not null,
	user_id uuid references users not null,
	is_admin boolean not null,
	create_timestamp timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
	constraint unique_room_user unique(room_id, user_id)
);

ALTER TABLE public.rooms OWNER to social_demo_admin;
GRANT SELECT ON TABLE public.rooms TO social_demo_api_role;

CREATE FUNCTION public.create_room(room new_room) RETURNS uuid
	LANGUAGE plpgsql
	AS $_$
	DECLARE
		_id uuid;
	BEGIN
		insert into rooms (owner_id, image_id, title, about)
		values (room.owner_id, room.image_id, room.title, room.about) returning id into _id;
		return _id;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.create_room(room new_room) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.create_room(room new_room) TO social_demo_api_role;

CREATE FUNCTION public.delete_room(room_id uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		DELETE FROM rooms WHERE id = room_id;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.delete_room(room_id uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.delete_room(room_id uuid) TO social_demo_api_role;

CREATE FUNCTION public.join_room(_user uuid, _room uuid, _admin boolean) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		insert into room_users (user_id, room_id, is_admin)
		values (_user, _room, _admin)
		on conflict(user_id, room_id) do update set is_admin = _admin;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.join_room(_user uuid, _room uuid, _admin boolean) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.join_room(_user uuid, _room uuid, _admin boolean) TO social_demo_api_role;

CREATE FUNCTION public.leave_room(_user uuid, _room uuid) RETURNS boolean
	LANGUAGE plpgsql
	AS $_$
	BEGIN
		DELETE FROM room_users WHERE user_id = user AND room_id = room;
		return true;
	END;
$_$ SECURITY DEFINER;

ALTER FUNCTION public.leave_room(_user uuid, _room uuid) OWNER TO social_demo_admin;
GRANT EXECUTE ON FUNCTION public.leave_room(_user uuid, _room uuid) TO social_demo_api_role;
