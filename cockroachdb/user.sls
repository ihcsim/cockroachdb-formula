{% from 'cockroachdb/map.jinja' import config with context %}

cockroachdb_user:
  user.present:
    - name: {{ config.user }}

cockroachdb_group:
  group.present:
    - name: {{ config.group }}
    - addusers:
      - {{ config.user }}
