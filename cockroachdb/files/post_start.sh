#!/bin/bash
# This shell script creates the database super user and its database after CockroachDB comes online.
# If an initdb.sql is present, it will be executed.

{% from 'cockroachdb/map.jinja' import config with context -%}
{% set runtime_options = '--insecure=' + config.insecure + ' --host=' + config.dbhost + ' --port=' + config.dbport -%}

until {{ config.home_dir }}/cockroach sql -e='SELECT 1' {{ runtime_options }}; do
  echo 'Waiting for CockroachDB to come online...'
  sleep 2
done

{% if config.initdb is defined %}
  {{ config.home_dir }}/cockroach user set {{ runtime_options }} {{ config.initdb.user }}
  {{ config.home_dir }}/cockroach sql -e 'CREATE DATABASE IF NOT EXISTS {{ config.initdb.database }}' {{ runtime_options }}
  {{ config.home_dir }}/cockroach sql -e 'GRANT ALL ON DATABASE {{ config.initdb.database }} TO {{ config.initdb.user }}' {{ runtime_options }}

  # If present, executes user-provided initdb.sql
  ls -al {{ config.home_dir }}
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
{% endif %}
