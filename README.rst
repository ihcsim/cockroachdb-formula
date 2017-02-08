===========
CockroachDB
===========
.. image:: https://app.codeship.com/projects/891b89d0-cb37-0134-f284-7288c1c90a91/status?branch=master :target: https://app.codeship.com/projects/199837)

Formula to install and configure `CockroachDB <https://github.com/cockroachdb/cockroach>`_.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================
.. contents::
    :local:

``cockroachdb``
-------------
This state installs a single instance of CockroachDB on a minion. The following is an example pillar to start a CockroachDB instance with a superuser ``devroach`` and its database ``devroach_sandbox``.

.. code:: yaml

  cockroachdb:
    initdb:
      dbuser: devroach
      database: devroach_sandbox

All the `start command <https://www.cockroachlabs.com/docs/start-a-node.html>`_ options can be specified at runtime using the ``cockroachdb.runtime_options`` pillar. For example, the following pillar will start an insecure CockroachDB instance, listening at IP address 192.168.50.11 and port 23600. Its data and log directories are located at ``/etc/cockroachdb/data`` and ``/var/log/cockroachdb``, respectively.

.. code:: yaml

  cockroachdb:
    runtime_options:
      - --insecure=true
      - --host=192.168.50.11
      - --port=26300
      - --store=path=/etc/cockroachdb/data
      - --log-dir=/var/log/cockroachdb

SQL queries that are added to the ``cockroachdb/scripts/initdb.sql`` script will automatically be executed as ``dbuser`` in the ``database`` on-start. If present on the minion's filesystem, this script will be re-executed when CockroachDB is restarted. Therefore, if it isn't safe to re-execute the SQL queries in this script, set the ``keep_initdb_sql`` pillar data to ``false`` (as seen in the ``pillar.example``) file to ensure that this file is deleted after first-run.

The ``cockroachdb/scripts/default.yml`` file contains a set of default values including URL to download the latest CockroachDB binary and user to run the CockroachDB service. These values can be overridden using pillar data.

``cockroachdb.docker``
---------------------
TBD

Testing
=======
Testing is done using `salt-kitchen <https://github.com/simonmcc/kitchen-salt>`_ and `serverspec <http://serverspec.org/>`_. These libraries will need to be installed before running the tests.

To run the test:

.. code:: sh

  $ bundle install
  $ kitchen test

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
