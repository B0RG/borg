require 'spec_helper'
require 'borg/configuration'

describe Borg::Configuration do
  it 'includes Applications, Assimilator, Stages, and UpstartTasks' do
    expect(
        Borg::Configuration.ancestors
    ).to include(Borg::Configuration::Applications,
                 Borg::Configuration::Assimilator,
                 Borg::Configuration::Stages)

  end

  describe '#_cset' do
    it 'does something' do

    end
  end
end
