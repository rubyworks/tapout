---
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Thomas Sawyer
  year: '2010'
  license: BSD-2-Clause
replacements: []
conflicts: []
requirements:
- name: ansi
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
dependencies: []
repositories:
- uri: git://github.com/rubyworks/tapout.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/tapout
  code: http://github.com/rubyworks/tapout
load_path:
- lib
extra:
  manifest: MANIFEST.txt
alternatives: []
revision: 0
name: tapout
title: Tapout
summary: Progressive TAP Harness
description: Tapout is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream
  and output it in a variety of useful formats.
organization: RubyWorks
created: '2010-12-23'
version: 0.1.0
date: '2011-07-28'
