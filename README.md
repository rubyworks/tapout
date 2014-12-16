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
gems by virtue of its use of TAP, a standardized intermediate test results
protocol.

TAPOUT works as a TAP handler which supports TAP-Y/J as well as traditional
TAP streams. TAP-Y/J is a modernization of TAP using pure YAML/JSON streams.
Traditional TAP has less detail than TAP-Y/J, but it can still be translated
with fairly good results. TAPOUT includes a TAP adapter to handle the
translation transparently. Currently TAPOUT supports TAP v12 with some minor
limitations.

To learn about the TAP-Y/J specification, see the [TAP-Y/J Specification](https://github.com/rubyworks/tapout/wiki/TAP-Y-J-Specification) document.

For information about TAP, see http://testanything.org/


## Usage

To learn more about using Tapout, please see the [wiki](https://github.com/rubyworks/tapout/wiki).
It provides more detailed information on how to put Tapout to work for you using your preferred
testing framework and build tool. What follows here is a very general overview of usage.

To use TAPOUT you need either a plugin for your current test framework, or use of
a test framework that supports TAP-Y/J out of the box. You can find a
[list of plugins here](https://github.com/rubyworks/tapout/wiki#producers)
under the section "Producers".

With a test framework that produces a TAP-Y/J output stream in hand pipe the
output stream into the `tapout` command by using a standard command line pipe.

    $ rubytest -y -Ilib test/foo.rb | tapout

TAPOUT supports a variety of output formats. The default is the common
dot-progress format (simply called `dot`). Other formats are selectable
via the `tapout` command's first argument.

    $ rubytest -y -Ilib test/foo.rb | tapout progressbar

TAPOUT is smart enough to match the closest matching format name. So, for
example, the above could be written as:

    $ rubytest -y -Ilib test/foo.rb | tapout pro

And tapout will know to use the `progressbar` format.

To see a list of supported formats use the list subcommand:

    $ tapout --help

If your test framework does not support TAP-Y/J, but does support traditional
TAP, TAPOUT will automatically recognize the difference by TAP's `1..N` header
and automatically translate it.

    $ rubytest -ftap -Ilib test/foo.rb | tapout progressbar


## Bypassing

Since tapout receives test results via a pipe, it has no direct control over
the producer, i.e the test runner. If you need to tell tapout to stop processing
the output then you can send a *PAUSE DOCUMENT* code. Likewise you can restart
processing by sending a *RESUME DOCUMENT* code. These codes are taken
from ASCII codes for DLE (Data Link Escape) and ETB (End of Transmission Block),
respectively. When tapout receives a *PAUSE DOCUMENT* code, it stops interpreting
any data it receives as test results and instead just routes `$stdin` back
to `$stdout` unmodified.

A good example of this is debugging with Pry using `binding.pry`.

    def test_something
      STDOUT.puts 16.chr  # tells tapout to pause processing
      binding.pry
      STDOUT.puts 23.char # tells tapout to start again
      assert something
    end

As it turns out, if your are using TAP-Y (not TAP-J) then you can also
use YAML's *END DOCUMENT* marker to acheive a similar result.

    def test_something
      STDOUT.puts "..."  # tells tapout to pause processing
      binding.pry
      assert something
    end

But this **only works for YAML** and if you happened to be debugging code
that emits YAML you might accidentally trigger tapout to resume. Therefore
it is recommended that the ASCII codes be used.

Note: When sending these codes, be sure to send a newline character as well.


## Legal

Copyright (c) 2010 Rubyworks

TAPOUT is modifiable and redistributable in accordance with the *BSD-2-Clause* license.

See COPYING.md for details.
