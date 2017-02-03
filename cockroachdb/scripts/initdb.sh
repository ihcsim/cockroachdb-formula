#!/bin/bash

# This shell script creates the database super user. (See default.yml for defaults.)
# If an initdb.sql is present, it will be executed.

{% from 'cockroachdb/map.jinja' import config with context %}

until {{ config.home_dir }}/cockroach sql --insecure --execute='SELECT 1'; do
  echo 'Waiting for CockroachDB to come online...'
  sleep 2
done

{{ config.home_dir }}/cockroach user set {{ config.dbuser }}
{{ config.home_dir }}/cockroach sql -e 'CREATE DATABASE {{ config.database }} IF NOT EXISTS'
{{ config.home_dir }}/cockroach sql -e 'GRANT ALL ON DATABASE {{ config.database }} TO {{ config.dbuser }}'
