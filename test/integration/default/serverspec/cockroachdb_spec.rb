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
      its(:args) { should contain '--store=path=/cockroachdb-data' }
    end

    describe port(26257) do
      it { should be_listening }
    end

    describe port(8080) do
      it { should be_listening }
    end

    describe file('/cockroachdb-data') do
      it { should be_a_directory }
      it { should be_owned_by 'cockroach' }
    end
  end
end
