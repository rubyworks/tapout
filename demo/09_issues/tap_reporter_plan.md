## TAP Reporter

### Issue #14 - tap reporter with skipped tests reports wrong number of tests

The tap reporter printed the plan, say `1..4`, and then a line for each
test that passed, failed or errored, but none for a test that was omitted
or still to be done. A stream with such tests came out short of its plan.

See https://github.com/rubyworks/tapout/issues/14.

    require 'stringio'

    tapy = <<-END.gsub(/^    /, '')
    ---
    type: suite
    count: 4
    ---
    type: test
    status: pass
    label: one
    ---
    type: test
    status: omit
    label: two
    exception:
      message: no network
    ---
    type: test
    status: todo
    label: three
    exception:
      message: soon
    ---
    type: test
    status: pass
    label: four
    ---
    type: final
    counts: {total: 4, pass: 2, fail: 0, error: 0, omit: 1, todo: 1}
    ...
    END

    stdout  = $stdout
    $stdout = StringIO.new(out = String.new)
    begin
      Tapout::YamlParser.new(:format => 'tap').consume(StringIO.new(tapy))
    ensure
      $stdout = stdout
    end

Every test now has its line, with TAP's directives for the two that
weren't run to a verdict.

    out.lines.map(&:chomp).assert == [
      '1..4',
      'ok 1 - one',
      'ok 2 - two # SKIP no network',
      'not ok 3 - three # TODO soon',
      'ok 4 - four'
    ]
