require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.default_facts = {
    :concat_basedir => File.join(fixture_path, 'concat_basedir')
  }
end

at_exit { RSpec::Puppet::Coverage.report! }
