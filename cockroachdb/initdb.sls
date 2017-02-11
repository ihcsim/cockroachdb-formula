# This state file defines the state to ensure that the user-provided SQL script is run after the CockroachDB instance is started successfully.

{% from 'cockroachdb/map.jinja' import config with context %}

include:
  - cockroachdb

cockroachdb_initdb_sql:
  file.managed:
    - name: {{ config.home_dir }}/initdb.sql
    - source: {{ config.initdb.sql.script }}
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - mode: 0755
    - require_in:
      - service: cockroachdb
