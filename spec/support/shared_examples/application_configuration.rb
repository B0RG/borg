shared_examples 'an application configuration' do
  context 'upon loading' do
    it 'creates and stores a new Application object with a name and execution block' do
      expect(config.applications[:app1].class).to eq Borg::Configuration::Applications::Application
      expect(config.applications[:app1].name).to eq :app1
    end

    it 'creates a new namespace value with a default task/description' do
      expect(config.namespaces[:app1]).to be_true
      expect(config.namespaces[:app1].tasks[:default]).to be_true
      expect(config.namespaces[:app1].tasks[:default].desc).to be_true
    end
  end
end
