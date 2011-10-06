--- 
name: tapout
dependencies: []

repositories: 
- name: upstream
  uri: git://github.com/rubyworks/tapout.git
  scm: git
conflicts: []

title: Tapout
copyrights: 
- license: BSD-2-Clause
  holder: Thomas Sawyer
  year: "2010"
replacements: []

date: "2011-09-26"
resources: 
  code: http://github.com/rubyworks/tapout
  home: http://rubyworks.github.com/tapout
version: 0.2.0
alternatives: []

requirements: 
- name: ansi
- groups: 
  - build
  name: detroit
  development: true
- groups: 
  - test
  name: qed
  development: true
revision: 0
organization: RubyWorks
summary: Progressive TAP Harness
authors: 
- name: Thomas Sawyer
  email: transfire@gmail.com
description: Tapout is a TAP consumer that can take any TAP, TAP-Y or TAP-J stream and output it in a variety of useful formats.
extra: 
  manifest: MANIFEST.txt
source: []

created: "2010-12-23"
load_path: 
- lib
