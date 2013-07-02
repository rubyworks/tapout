# TAPOUT

[Website](http://rubyworks.github.com/tapout) |
[User Guide](http://github.com/rubyworks/tapout/wiki) |
[Report Issue](http://github.com/rubyworks/tapout/issues) |
[Development](http://github.com/rubyworks/tapout)

[![Build Status](https://secure.travis-ci.org/rubyworks/tapout.png)](http://travis-ci.org/rubyworks/tapout)
[![Gem Version](https://badge.fury.io/rb/tapout.png)](http://badge.fury.io/rb/tapout) &nbsp; &nbsp;
[![Flattr Me](http://api.flattr.com/button/flattr-badge-large.png)](http://flattr.com/thing/324911/Rubyworks-Ruby-Development-Fund)


## About

*TAPOUT* is the next generation in test results viewing. You may have heard
of Turn or minitest-reporters. TAPOUT is the conceptual successor to these
gems by virture of its use of TAP, a standardized intermediate test results
protocol. 

TAPOUT works as a TAP handler which supports TAP-Y/J as well as traditional
TAP streams. TAP-Y/J is a modernization of TAP using pure YAML/JSON streams.
Traditional TAP has less detail than TAP-Y/J, but it can still be translated
with fairly good results. TAPOUT includes a TAP adapter to handle the
translation transparently. Currently TAPOUT supports TAP v12 with some minor
limitations.

To learn about the TAP-Y/J specification, see the [TAP-Y/J Specification](https://github.com/rubyworks/tapout/wiki/Specification) document.

For information about TAP, see http://testanything.org/wiki/index.php/Main_Page.


## Usage

To use TAPOUT you need either a plugin for your current test framework, or use of
a test framework that supports TAP-Y/J out of the box. You can find a 
[list of plugins here](https://github.com/rubyworks/tapout/wiki)
under the section "Producers".

Using a test framework that produces a TAP-Y output stream, simply pipe
the stream into `tapout`.

    $ rubytest -y -Ilib test/foo.rb | tapout

TAPOUT supports a variety of output formats. These are selectable via the 
first argument. The default if not given, as in the example above, is `dot`.

    $ rubytest -y -Ilib test/foo.rb | tapout progessbar

TAPOUT is smart enough to match the closest matching format name. So, for
example, the above could be written as:

    $ rubytest -y -Ilib test/foo.rb | tapout pro

And tapout will know to use the `progressbar` format.

To see a list of supported formats use the list subcommand:

    $ tapout --help

If your test framework does not support TAP-Y, but does support traditional
TAP, TAPOUT will automatically recognize the difference by TAP's `1..N` header.

    $ rubytest -ftap -Ilib test/foo.rb | tapout progressbar


## Legal

Copyright (c) 2010 Rubyworks

TAPOUT is modifiable and redistributable in accordance with the *BSD-2-Clause* license.

See COPYING.md for details.

