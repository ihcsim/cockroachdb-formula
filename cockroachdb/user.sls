# This state file defines the states to ensure the user and group to run the CockroachDB process are present.

{% from 'cockroachdb/map.jinja' import config with context %}

cockroachdb_user:
  user.present:
    - name: {{ config.ps.user }}

cockroachdb_group:
  group.present:
    - name: {{ config.ps.group }}
    - addusers:
      - {{ config.ps.user }}
