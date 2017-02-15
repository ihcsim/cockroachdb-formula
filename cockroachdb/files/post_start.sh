#!/bin/bash
# This shell script creates the database super user and its database after CockroachDB comes online.
# If an initdb.sql is present, it will be executed.

{% from 'cockroachdb/map.jinja' import config with context -%}

{% set runtime_options = '' -%}
{% if config.insecure is defined -%}
  {% set runtime_options = runtime_options ~ '--insecure=' ~ config.insecure -%}
{% endif -%}
{% if config.dbhost is defined -%}
  {% set runtime_options = runtime_options ~ ' --host=' ~ config.dbhost -%}
{% endif -%}
{% if config.dbport is defined -%}
  {% set runtime_options = runtime_options ~ ' --port=' ~ config.dbport -%}
{% endif -%}

until {{ config.home_dir }}/cockroach sql -e='SELECT 1' {{ runtime_options }}; do
  echo 'Waiting for CockroachDB to come online...'
  sleep 2
done

{%- if config.initdb is defined %}
{{ config.home_dir }}/cockroach user set {{ runtime_options }} {{ config.initdb.user }}
{{ config.home_dir }}/cockroach sql -e 'CREATE DATABASE IF NOT EXISTS {{ config.initdb.database }}' {{ runtime_options }}
{{ config.home_dir }}/cockroach sql -e 'GRANT ALL ON DATABASE {{ config.initdb.database }} TO {{ config.initdb.user }}' {{ runtime_options }}

# If present, executes user-provided initdb.sql
if [ -e "{{ config.home_dir }}/initdb.sql" ];
then
  echo "Executing {{ config.home_dir }}/initdb.sql..."
  {{ config.home_dir }}/cockroach sql --user {{ config.initdb.user }} --database {{ config.initdb.database }} {{ runtime_options }} < {{ config.home_dir }}/initdb.sql

  if [ '{{ config.initdb.sql.keep }}' == 'False' ];
  then
    echo "Removing {{ config.home_dir }}/initdb.sql..."
    rm -f {{ config.home_dir }}/initdb.sql
  fi
fi
{% endif -%}
