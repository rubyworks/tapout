require_relative 'lib/tapout/version'

Gem::Specification.new do |s|
  s.name        = 'tapout'
  s.version     = Tapout::VERSION
  s.summary     = 'Progressive TAP Harness'
  s.description = 'Tapout is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream ' \
                  'and output it in a variety of useful formats.'

  s.authors  = ['Trans']
  s.email    = ['transfire@gmail.com']
  s.homepage = 'https://rubyworks.github.io/tapout'
  s.license  = 'BSD-2-Clause'

  s.metadata = {
    'homepage_uri'      => s.homepage,
    'source_code_uri'   => 'https://github.com/rubyworks/tapout',
    'bug_tracker_uri'   => 'https://github.com/rubyworks/tapout/issues',
    'changelog_uri'     => 'https://github.com/rubyworks/tapout/blob/master/HISTORY.md',
    'documentation_uri' => 'https://rubydoc.info/gems/tapout'
  }

  s.required_ruby_version = '>= 2.7'

  s.files = Dir[
    'lib/**/*.rb', 'bin/*', 'demo/**/*',
    '.yardopts', 'README.md', 'HISTORY.md', 'COPYING.md', 'TAP-YJ.md'
  ]
  s.bindir           = 'bin'
  s.executables      = ['tapout']
  s.require_paths    = ['lib']
  s.extra_rdoc_files = ['COPYING.md', 'HISTORY.md', 'README.md', 'TAP-YJ.md']

  s.add_dependency 'ansi', '>= 1.5'
  s.add_dependency 'json'

  s.add_development_dependency 'rake', '>= 13'
  s.add_development_dependency 'qed', '>= 2.9'
  s.add_development_dependency 'ae', '>= 1.8'
end
