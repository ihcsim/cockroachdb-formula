# This state file ensures that the specified version of CockroachDB is downloaded, extracted, enabled and run.

{% from 'cockroachdb/map.jinja' import config with context %}

include:
  - cockroachdb/user

cockroachdb_service:
  service.running:
    - name: cockroachdb
    - enable: True
    - require:
      - cockroachdb_install
    - watch:
      - cockroachdb_unit_file

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

cockroachdb_unit_file:
  file.managed:
    - name: /etc/systemd/system/cockroachdb.service
    - source: salt://cockroachdb/scripts/cockroachdb.service
    - user: {{ config.user }}
    - group: {{ config.group }}
    - template: jinja

cockroachdb_initdb:
  file.managed:
    - name: {{ config.home_dir }}/initdb.sh
    - source: salt://cockroachdb/scripts/initdb.sh
    - template: jinja
    - user: {{ config.user }}
    - group: {{ config.group }}
    - mode: 0755
