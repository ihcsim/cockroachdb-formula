# This state file defines the states to ensures that the latest version of CockroachDB is downloaded, extracted, enabled and run.
# These states also ensure the database super user and its database are present in the CockroachDB.
# User-provided SQL queries in the initdb.sql script are executed once the CockroachDB is running.

{% from 'cockroachdb/map.jinja' import config with context %}

include:
  - cockroachdb/user

cockroachdb_install:
  archive.extracted:
    - name: {{ config.home_dir }}
    - source: {{ config.download_url }}
    - options: --strip-components 1
    - enforce_toplevel: False
    - user: {{ config.user }}
    - group: {{ config.group }}
    - enforce_ownership_on: {{ config.home_dir }}
    - skip_verify: True
    - makedirs: True

cockroachdb_initdb_sh:
  file.managed:
    - name: {{ config.home_dir }}/initdb.sh
    - source: salt://cockroachdb/scripts/initdb.sh
    - template: jinja
    - user: {{ config.user }}
    - group: {{ config.group }}
    - mode: 0755

cockroachdb_initdb_sql:
  file.managed:
    - name: {{ config.home_dir }}/initdb.sql
    - source: salt://cockroachdb/scripts/initdb.sql
    - user: {{ config.user }}
    - group: {{ config.group }}

cockroachdb_unit_file:
  file.managed:
    - name: /etc/systemd/system/cockroachdb.service
    - source: salt://cockroachdb/scripts/cockroachdb.service
    - user: {{ config.user }}
    - group: {{ config.group }}
    - template: jinja

cockroachdb_service:
  service.running:
    - name: cockroachdb
    - enable: True
    - watch:
      - cockroachdb_unit_file
      - cockroachdb_initdb_sh
