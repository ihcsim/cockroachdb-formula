===========
CockroachDB
===========
.. image:: https://app.codeship.com/projects/94529550-d1e9-0134-7c93-0275da32878f/status?branch=master
  :target: https://app.codeship.com/projects/201690)

Formula to install and configure `CockroachDB <https://github.com/cockroachdb/cockroach>`_.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================
.. contents::
    :local:

``cockroachdb``
---------------
This state installs a single instance of CockroachDB on a minion. All supported runtime options can be passed to the instance using the ``cockroachdb.runtime_options`` pillar. The following pillar starts an insecure CockroachDB instance at localhost:26257, configured to write its data to ``/opt/cockroachdb/data`` and logs to ``/opt/cockroachdb/log``.

.. code:: yaml

  cockroachdb:
    runtime_options:
      - --insecure=true
      - --host=localhost
      - --port=26257
      - --store=path=/opt/cockroachdb/data
      - --log-dir=/opt/cockroachdb/log

The ``cockroachdb/scripts/default.yml`` file contains a set of default values that can be overridden using pillar data.

To start a [cluster](https://www.cockroachlabs.com/docs/start-a-local-cluster.html), provide the `--join` flag to the ``cockroachdb.runtime_options`` pillar. For example to start a cluster of 3 instances, namely, ``db-01``, ``db-02``, ``db-03``) and run a user-provided ``initdb.sql`` SQL script,

``salt/top.sls``
.. code:: yaml

  base:
    'db-01':
      - cockroachdb.initdb
    'not db-01':
      - cockroachdb

``pillar/top.sls``
.. code:: yaml

  base:
    'db-01':
      - cockroachdb.initdb
    'not db-01':
      - cockroachdb.cluster

``pillar/cockroachdb/initdb.sls``

  {% set ipv4_addrs = {'private':'127.0.0.1', 'public':'127.0.0.1'} -%}
  {% for ipv4_addr in salt['grains.get']('ipv4', '127.0.0.1') -%}
    {% if salt['network.is_private'](ipv4_addr) %}
      {% do ipv4_addrs.update({'private': ipv4_addr}) %}
    {% elif not salt['network.is_private']('ipv4_addr') and not salt['network.is_loopback']('ipv4_addr') %}
      {% do ipv4_addrs.update({'public': ipv4_addr}) %}
    {% endif %}
  {% endfor -%}
  cockroachdb:
    initdb:
      user: maxroach
      database: maxroachdb

      sql:
        script: salt://cockroachdb/files/initdb.sql
        keep: false

		runtime_options:
			- --insecure=true
			- --host={{ ipv4_addrs['private'] }}
			- --port=26257
			- --http-host={{ ipv4_addrs['public'] }}
			- --http-port=7070
			- --store=path=/etc/cockroachdb/data
			- --log-dir=/var/log/cockroachdb

``pillar/cockroachdb/cluster.sls``

	{% set ipv4_addrs = {'private':'127.0.0.1', 'public':'127.0.0.1'} -%}
	{% for ipv4_addr in salt['grains.get']('ipv4', '127.0.0.1') -%}
		{% if salt['network.is_private'](ipv4_addr) %}
			{% do ipv4_addrs.update({'private': ipv4_addr}) %}
		{% endif %}
	{% endfor -%}
	cockroachdb:
		runtime_options:
			- --join=<db-01-static-ipv4-address>
			- --insecure=true
			- --host={{ ipv4_addrs['private'] }}
			- --port=26257
			- --store=path=/opt/cockroachdb/data
			- --log-dir=/opt/cockroachdb/log

``cockroachdb.initdb``
----------------------
This state initializes the CockroachDB instance with a user-provided superuser and its database. In addition, a user-provided SQL script located at ``cockroachdb.initdb.sql.script`` is executed on-start. The following pillar instructs CockroachDB to create a superuser ``maxroach`` and its database ``maxroachdb`` after the instance is started successfully. Any SQL queries provided at ``cockroachdb/files/queries.sql`` will be also run after the instance is ready.

.. code:: yaml

  cockroachdb:
    initdb:
      dbuser: maxroach
      database: maxroachdb

      sql:
        script: salt://cockroachdb/files/queries.sql

An example user-provided SQL script can be found in ``cockroachdb/files/initdb.sql``. This script will automatically be executed as ``cockroachdb.initdb.dbuser`` in ``cockroachdb.initdb.database`` on-start. This script will be re-executed on-restart. The minion can be instructed to delete this SQL script after the first execution using the ``cockroachdn.initdb.sql.keep`` pillar data.

The ``pillar.example`` file provides further example.

Testing
=======
Testing is done using `salt-kitchen <https://github.com/simonmcc/kitchen-salt>`_ and `serverspec <http://serverspec.org/>`_. These libraries will need to be installed before running the tests. To run the test:

.. code:: sh

  $ bundle install
  $ kitchen test

Here's a summary of the test suites:

+--------------+-------------------------------------------------+-----------------------------+
| Test Suites  | Description                                     | Paths                       |
+--------------+-------------------------------------------------+-----------------------------+
| ``default``  | Use ``cockroachdb/default.yml`` as pillar source| ``test/integration/default``|
+--------------+-------------------------------------------------+-----------------------------+
| ``pillar``   | Use ``pillar.example`` as pillar source         | ``test/integration/pillar`` |
+--------------+-------------------------------------------------+-----------------------------+
| ``initdb``   | Test initdb behaviour                           | ``test/integration/initdb`` |
+--------------+-------------------------------------------------+-----------------------------+

``kitchen test`` is the meta-action that automates all the end-to-end test actions. To speed up the development test-code-verify cycle, use the ``converge`` and ``verify`` actions:

.. code:: sh

  $ kitchen create
  $ kitchen converge
  $ kitchen verify

If an error occurred complaining that `Vagrant is unable to mount the VirtualBox shared file system because vboxsf is not available <http://stackoverflow.com/q/22717428/1144203>`_, then run the following command to install the VirtualBox guest additions:

.. code:: shell

  $ vagrant plugin install vagrant-vbguest

License
=======
Refers to the `LICENSE <LICENSE>`_ file. CockroachDB is an `open source project <https://github.com/cockroachdb/cockroach/blob/master/LICENSE>`_.
