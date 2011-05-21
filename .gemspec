--- !ruby/object:Gem::Specification 
name: tapout
version: !ruby/object:Gem::Version 
  prerelease: 
  version: 0.1.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-05-21 00:00:00 Z
dependencies: 
- !ruby/object:Gem::Dependency 
  name: ansi
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :runtime
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: redline
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id002
- !ruby/object:Gem::Dependency 
  name: qed
  prerelease: false
  requirement: &id003 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id003
description: Tap Out is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream and output it in a variety of useful formats.
email: transfire@gmail.com
executables: 
- tapout
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- .ruby
- bin/tapout
- lib/tapout/reporters/abstract.rb
- lib/tapout/reporters/breakdown.rb
- lib/tapout/reporters/dotprogress.rb
- lib/tapout/reporters/progressbar.rb
- lib/tapout/reporters/tap.rb
- lib/tapout/reporters/verbose.rb
- lib/tapout/reporters.rb
- lib/tapout/tap_legacy_adapter.rb
- lib/tapout/tap_legacy_parser.rb
- lib/tapout/tapy_parser.rb
- lib/tapout/version.rb
- lib/tapout.rb
- qed/applique/env.rb
- qed/tap_adapter.rdoc
- HISTORY.rdoc
- APACHE2.txt
- README.rdoc
- TAP-YJ.rdoc
- NOTICE.rdoc
homepage: http://rubyworks.github.com/tapout
licenses: 
- Apache 2.0
post_install_message: 
rdoc_options: 
- --title
- Tap Out API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
requirements: []

rubyforge_project: tapout
rubygems_version: 1.8.2
signing_key: 
specification_version: 3
summary: Progressive TAP Harness
test_files: []

