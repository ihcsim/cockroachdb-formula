require 'serverspec'

set :path, '/opt/cockroachdb:$PATH'
set :backend, :exec

describe 'Pillar source: cockroachdb/default.yml' do
  describe service('cockroachdb') do
    it { should be_enabled }
    it { should be_running }
  end

  context 'Given a list of runtime_options' do
    describe process('cockroach') do
      its(:user) { should eq 'cockroach' }
      its(:group) { should eq 'cockroach' }
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
