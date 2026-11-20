# Sparse Streams

A test that didn't pass is meant to carry an `exception` section, but only
its `message` is required, and not every producer gives even that. Rubytest
gives no exception class, and a backtrace only for errors. Plain TAP gives
nothing at all for a failed test. Every reporter has to cope.

    require 'stringio'

    run = lambda do |format, text, parser = Tapout::YamlParser|
      stdout, stderr = $stdout, $stderr
      $stdout = StringIO.new(out = String.new)
      $stderr = StringIO.new(String.new)
      begin
        parser.new(:format => format).consume(StringIO.new(text))
      ensure
        $stdout, $stderr = stdout, stderr
      end
      out
    end

    reporters = %w[dot progress outline pretty breakdown runtime tap turn markdown html]

Here a failure has a message and a location but no class or backtrace, an
error has a message alone, and another failure has no exception section.

    sparse = <<-END.gsub(/^    /, '')
    ---
    type: suite
    count: 6
    rev: 5
    ---
    type: case
    level: 0
    label: Sparse
    ---
    type: test
    status: pass
    label: passes
    ---
    type: test
    status: fail
    label: fails
    exception:
      file: test/sparse.rb
      line: 9
      message: wrong value
    ---
    type: test
    status: error
    label: errors
    exception:
      message: boom
    ---
    type: test
    status: fail
    label: fails without saying why
    ---
    type: test
    status: todo
    label: is pending
    exception:
      message: later
    ---
    type: test
    status: omit
    label: is omitted
    ---
    type: final
    counts:
      total: 6
      pass: 1
      fail: 2
      error: 1
      omit: 1
      todo: 1
    ...
    END

    reporters.each do |format|
      run.call(format, sparse).empty?.assert == false
    end

The same goes for tests that belong to no case, as in a stream converted
from plain TAP.

    plain = <<-END.gsub(/^    /, '')
    TAP version 13
    1..4
    ok 1 - passes
    not ok 2 - fails
    ok 3 - is skipped # SKIP no network
    not ok 4 - is pending # TODO soon
    END

    reporters.each do |format|
      run.call(format, plain, Tapout::PerlParser).empty?.assert == false
    end
