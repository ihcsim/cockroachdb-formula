#!/bin/bash

{% from 'cockroachdb/map.jinja' import config with context %}

until {{ config.home_dir }}/cockroach sql --insecure --execute='SELECT 1'; do
  echo 'Waiting for CockroachDB to come online...'
  sleep 2
done
