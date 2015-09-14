require 'spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

describe 'sudo', :type => 'class' do
  context 'with defaults for all parameters' do
    let(:facts) {
      {:concat_basedir => File.join(fixture_path, 'concat_basedir')}
    }

    it {
      should compile.with_all_deps
      should contain_class('sudo')
      should contain_package('sudo')
    }
  end
end
