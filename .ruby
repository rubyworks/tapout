--- 
name: koax
company: RubyWorks
title: Koax
contact: trans <transfire@gmail.com>
pom_verison: 1.0.0
requires: 
- group: []

  name: ansi
  version: 0+
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - buidl
  name: qed
  version: 0+
resources: 
  repository: git://github.com/proutils/koax.git
  home: http://proutils.github.com/koax
manifest: 
- .ruby
- bin/koax
- lib/koax/reporters/abstract.rb
- lib/koax/reporters/breakdown.rb
- lib/koax/reporters/dotprogress.rb
- lib/koax/reporters/progressbar.rb
- lib/koax/reporters/tap.rb
- lib/koax/reporters/verbose.rb
- lib/koax/reporters.rb
- lib/koax/tap_legacy_adapter.rb
- lib/koax/tap_legacy_parser.rb
- lib/koax/tapy_parser.rb
- lib/koax/version.rb
- lib/koax.rb
- spec/applique/env.rb
- spec/tap_adapter.rdoc
- Profile
- LICENSE
- README.rdoc
- TAP-Y.rdoc
version: 0.1.0
licenses: 
- Apache 2.0
copyright: Copyright (c) 2010 Thomas Sawyer
description: Koax is TAP consumer that can take any TAP, TAP-Y or TAP-J stream and output it into a variety of useful formats.
summary: A Coaxing TAP Harness
authors: 
- Thomas Sawyer
created: 2010-12-23
