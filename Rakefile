# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'ckuru-tools'

task :default => 'spec:run'

PROJ.name = 'ckuru-tools'
PROJ.authors = 'Bret'
PROJ.email = 'bret@ckuru.com'
PROJ.url = 'http://ckuru.com'
PROJ.rubyforge.name = 'ckuru-tools'

PROJ.spec.opts << '--color'

# EOF
