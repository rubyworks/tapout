# TAP Parser

Given a legacy TAP stream:

    1..3
    ok 1 - Example A
    not ok 2 - Example B
      ---
      file:        foo.rb
      line:        45
      description: this is that
      found:       this
      wanted:      that
      raw_test:    assert_equal('that', 'this')
      extensions:
        THAC0:     16
      ...
    ok 3

The PerlAdapter can convert the stream into TAP-Y.

    stream = StringIO.new(@tap)

    adapter = Tapout::PerlAdapter.new(stream)

    entries = adapter.to_a

Once converted, there should five entries --a header and footer, two
passing tests and one failing test.

    entries.size.assert == 5

Or pipe the converted stream directly to another stream.

    stream = StringIO.new(@tap)

    adapter = Tapout::PerlAdapter.new(stream)

    output = String.new

    tapy = adapter | output

Given a legacy TAP stream:

    1..5
    # test by equality
    ok 1 - pass-thru 1
    ok 2 - pass-thru 2
    ok 3 - pass-thru 3
    ok 4 - pass-thru 4
    ok 5 - pass-thru 5
    1..5

Let's see if this works.

    stream = StringIO.new(@tap)

    adapter = Tapout::PerlAdapter.new(stream)

    entries = adapter.to_a

Once converted, there should eight entries --a header and footer, one note
and five passing tests.

    entries.size.assert == 8


## Version line and directives

A stream may open with a version line, and a test line may end with a
`SKIP` or `TODO` directive. Given a legacy TAP stream:

    TAP version 13
    1..5
    ok 1 - passes
    not ok 2 - fails
    ok 3 - is skipped # SKIP no network
    not ok 4 - is pending # TODO soon
    ok
    
The version line is ignored. A skipped test becomes an `omit` and a test
still to be done a `todo`, each with its reason as the message. A test
without a number takes the next one.

    entries = Tapout::PerlAdapter.new(StringIO.new(@tap)).to_a

    tests = entries.select{ |e| e['type'] == 'test' }

    tests.map{ |e| e['status'] }.assert == %w[pass fail omit todo pass]
    tests.map{ |e| e['label'] }.assert == ['passes', 'fails', 'is skipped', 'is pending', '']
    tests.map{ |e| e['index'] }.assert == [1, 2, 3, 4, 5]

    tests[2]['exception']['message'].assert == 'no network'
    tests[3]['exception']['message'].assert == 'soon'

The final entry counts each kind.

    entries.last['counts'].assert == {
      'total' => 5, 'pass' => 2, 'fail' => 1, 'error' => 0, 'omit' => 1, 'todo' => 1
    }
