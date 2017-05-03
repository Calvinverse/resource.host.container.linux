require 'spec_helper'

describe 'resource_container_host_linux::consul' do
  context 'imports the recipes' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'has the correct platform_version' do
      expect(chef_run.node['platform_version']).to eq('16.04')
    end

    it 'imports the consul recipe' do
      expect(chef_run).to include_recipe('consul::default')
    end
  end
end
