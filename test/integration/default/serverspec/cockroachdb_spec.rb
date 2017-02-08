require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'CockroachDB' do
  context 'When started as a service on a minion' do
    describe service('cockroachdb') do
      it { should be_enabled }
      it { should be_running }
    end

		set :env, :COCKROACH_INSECURE => 'true', :COCKROACH_HOST => '192.168.50.11', :COCKROACH_PORT => '26300'

    # pillar data used for these tests are found in the pillar.example file
    context 'Given the `dbuser=devroach` and `database=devroach_sandbox` pillar data' do
      describe command('cockroach sql -e "SHOW USERS" --pretty=false') do
        its(:stdout) do
          should contain 'devroach'
        end
      end

      describe command('cockroach sql -e "SHOW DATABASES" --pretty=false') do
        its(:stdout) do
          should contain 'devroach_sandbox'
        end
      end
    end

    context 'Given the `keep_initdb_sql=false` pillar data' do
      describe file('/opt/cockroachdb/initdb.sql') do
        it { should_not exist }
      end
    end

    context 'Given the `runtime_options` pillar data' do
      describe process('cockroach') do
        its(:args) { should contain '--insecure=true --host=192.168.50.11 --port=26300 --http-host=192.168.50.11 --http-port=7070 --store=path=/etc/cockroachdb/data --log-dir=/var/log/cockroachdb' }
      end
    end

    # SQL queries used for this test are found in scripts/initdb.sql
    context 'Given sample customer test data' do
      describe command('cockroach sql --user devroach --database devroach_sandbox -e "SHOW TABLES" --pretty=false') do
        its(:stdout) do
          should contain 'customers'
        end
      end

      describe command('cockroach sql --user devroach --database devroach_sandbox -e "SELECT * FROM customers" --pretty=false') do
        its(:stdout) do
          should contain '3 rows'
        end

        its(:stdout) do
          should contain '1000\tJohn\tSmith\n1001\tBarbara\tLee\n1002\tAlbert\tKrahn\n'
        end
      end
    end
  end
end
