require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'InitDB' do
  describe service('cockroachdb') do
    it { should be_enabled }
    it { should be_running }
  end

	set :env, :COCKROACH_INSECURE => 'true', :COCKROACH_HOST => 'localhost', :COCKROACH_PORT => '26257'

  context 'Given dbuser: oldroach' do
    describe command('cockroach sql -e "SHOW USERS" --format=tsv') do
      its(:stdout) { should contain 'oldroach' }
    end
  end

  context 'Given database: oldroach_sandbox' do
    describe command('cockroach sql -e "SHOW DATABASES" --format=tsv') do
      its(:stdout) { should contain 'oldroach_sandbox' }
    end
  end

  context 'Given keep_initdb_sql: true' do
    describe file('/opt/cockroachdb/initdb.sql') do
      it { should exist }
    end
  end

  context 'Given scripts/initdb.sql with sample test data' do
    describe command('cockroach sql --user oldroach --database oldroach_sandbox -e "SHOW TABLES" --format=tsv') do
      its(:stdout) { should contain 'customers' }
    end

    describe command('cockroach sql --user oldroach --database oldroach_sandbox -e "SELECT * FROM customers" --format=tsv') do
      its(:stdout) { should contain '3 rows' }
      its(:stdout) { should contain '1000\tJohn\tSmith\n1001\tBarbara\tLee\n1002\tAlbert\tKrahn\n' }
    end
  end
end
