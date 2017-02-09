require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'Pillar source: cockroachdb/default.yml' do
  describe service('cockroachdb') do
    it { should be_enabled }
    it { should be_running }
  end

  set :env, :COCKROACH_INSECURE => 'true', :COCKROACH_HOST => 'localhost', :COCKROACH_PORT => '26257'

  context 'Given dbuser: maxroach' do
    describe command('cockroach sql -e "SHOW USERS" --format=tsv') do
      its(:stdout) { should contain 'maxroach' }
    end
  end

  context 'Given database: roach_sandbox' do
    describe command('cockroach sql -e "SHOW DATABASES" --format=tsv') do
      its(:stdout) { should contain 'maxroach_sandbox' }
    end
  end

  context 'Given keep_initdb_sql: false' do
    describe file('/opt/cockroachdb/initdb.sql') do
      it { should_not exist }
    end
  end

  context 'Given a list of runtime_options' do
    describe process('cockroach') do
      its(:args) { should contain '--insecure=true --host=localhost --port=26257 --store=path=/opt/cockroachdb/data --log-dir=/opt/cockroachdb/log' }
    end

    describe file('/opt/cockroachdb/data') do
      it { should be_a_directory }
      it { should be_owned_by 'cockroach' }
    end

    describe file('/opt/cockroachdb/log') do
      it { should be_a_directory }
      it { should be_owned_by 'cockroach' }
    end
  end
end
