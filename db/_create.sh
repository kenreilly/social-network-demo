#!/usr/bin/env bash
psql postgres -f init.sql
psql social_demo -f core.sql
psql social_demo -f images.sql 
psql social_demo -f users.sql
psql social_demo -f posts.sql
psql social_demo -f followers.sql