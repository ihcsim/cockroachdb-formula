# This state file defines the states to ensures that the latest version of CockroachDB is downloaded, extracted, enabled and run.

{% from 'cockroachdb/map.jinja' import config with context %}

include:
  - cockroachdb/user

cockroachdb_install:
  archive.extracted:
    - name: {{ config.home_dir }}
    - source: {{ config.download_url }}
    - options: --strip-components 1
    - enforce_toplevel: False
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - enforce_ownership_on: {{ config.home_dir }}
    - skip_verify: True
    - makedirs: True

cockroachdb_post_start:
  file.managed:
    - name: {{ config.home_dir }}/post_start.sh
    - source: {{ config.ps.post_start_tmpl }}
    - template: jinja
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - mode: 0755

{% if config.datadir is defined %}
cockroachdb_data_directory:
  file.directory:
    - name: {{ config.datadir }}
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% if config.logdir is defined %}
cockroachdb_log_folder:
  file.directory:
    - name: {{ config.logdir }}
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - dir_mode: 755
    - makedirs: True
{% endif %}

cockroachdb_unit_file:
  file.managed:
    - name: /etc/systemd/system/cockroachdb.service
    - source: {{ config.ps.unit_file_tmpl }}
    - user: {{ config.ps.user }}
    - group: {{ config.ps.group }}
    - template: jinja
    - watch_in:
      - service: cockroachdb_service

cockroachdb_service:
  service.running:
    - name: cockroachdb
    - enable: True
