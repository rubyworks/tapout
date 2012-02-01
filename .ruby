---
source:
- var
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Thomas Sawyer
  year: '2010'
  license: BSD-2-Clause
replacements: []
alternatives: []
requirements:
- name: ansi
- name: json
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
dependencies: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/tapout.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/tapout
  code: http://github.com/rubyworks/tapout
extra: {}
load_path:
- lib
revision: 0
created: '2010-12-23'
summary: Progressive TAP Harness
title: TAPOUT
version: 0.4.0
name: tapout
description: Tapout is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream
  and output it in a variety of useful formats.
organization: RubyWorks
date: '2012-02-01'
