--- 
spec_version: 1.0.0
replaces: []

loadpath: 
- lib
name: tapout
repositories: 
  public: git://github.com/proutils/tapout.git
conflicts: []

engine_check: []

title: Tap Out
contact: trans <transfire@gmail.com>
resources: 
  code: http://github.com/rubyworks/tapout
  home: http://rubyworks.github.com/tapout
maintainers: []

requires: 
- group: []

  name: ansi
  version: 0+
- group: 
  - build
  name: redline
  version: 0+
- group: 
  - build
  name: qed
  version: 0+
manifest: MANIFEST.txt
version: 0.1.0
licenses: 
- Apache 2.0
copyright: Copyright (c) 2010 Thomas Sawyer
authors: 
- Thomas Sawyer
organization: RubyWorks
description: Tap Out is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream and output it in a variety of useful formats.
summary: Progressive TAP Harness
created: 2010-12-23
