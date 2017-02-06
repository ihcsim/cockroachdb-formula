require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'CockroachDB' do
  context 'When started as a service on a minion' do
    describe service('cockroachdb') do
      it { should be_enabled }
      it { should be_running }
    end

    context 'Given the pillar data dbuser=devroach and database=devroach_sandbox' do
      # pillar data used for this test is found in the pillar.example file
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

    context 'Given the pillar data keep_initdb_sql=false' do
      # pillar data used for this test is found in the pillar.example file
      describe file('/opt/cockroachdb/initdb.sql') do
        it { should_not exist }
      end
    end

    context 'Given sample customer test data' do
      # SQL queries used for this test are found in scripts/initdb.sql

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
