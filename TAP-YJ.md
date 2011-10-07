# TAP-Y/J Format

TAP-Y and TAP-J are test streams. They are essentially the same except
for the underlying format used, which are YAML and JSON repsectively.

The following overview will use the YAML format. Becuase the YAML format 
is a plan format, not using an special YAML tags, it is easy to convert
to JSON to get the equivalent TAP-J format. TAP-J documents follow all the
same feild rules as TAP-Y, but are represented as a stream of JSON 
documents, one per line, instead of YAML documents.

## Structure

TAP-Y is a plain YAML stream format. Only YAML core types are used: 
scalar, sequence and mapping.

A YAML stream is composed a sequence of YAML *documents*, each divided by
a start document marker (<code>---</code>). Each document MUST have a `type`
field which designates it a `suite`, `case`, `test`, `note` or `tally`. Any
document MAY have an `extra` entry which contains an open mapping for
extraneous information.

### Suite

A `suite` document marks the beginning of a forthcoming stream of tests,
i.e. a <i>test suite</i>. All TAP-Y streams MUST begin with a suite
document.

    ---
    type: suite
    start: 2011-10-10 12:12:32
    count: 2
    seed: 32154
    rev: 2

The `start` field marks the date and time testing began. It MUST be
an ISO-8601 formated timestamp.

The `count` field indicates the total number of test units forethcoming.
If the number of test units is unknown, the total can be omitted or 
marked as `~` (nil). The total should only indicate the number of
<i>test units</i>, not any enumeration of <i>test cases</i>.

The `seed` is provided if the test runner has randomized the order of
execution unit tests. The seed can be used to reproduce the same order.

The `rev` field provides the version of the TAP-Y/J format that is
being used. The specification will change little, if at all, as it
become more mainstream. But just in case, having a revision field
ensures things will work if they do change by allowing consuming
apps to adjust to any future variation.

### Case

The `case` type indicates the start of a test case.

    ---
    type: case
    subtype: feature
    label: Multiplication
    level: 0

The case document MAY provide a `class` which is a label for the
typ of test case. For example, a test framwework that uses Gherkin
nomenclature would classify a test case as a "feature".

The case document SHOULD provide a `label` that is a free-form string
describing the nature of the test case.

The `level` field is used to notate sub-case heiararchies. By default the
value is assumed to be `0`, which means the case is not a subcase. If `1`
than the it indicates that the case is a subcase of the previous zero-level
case, and so on for higher levels. Subcases should proceed sequentially.
If a case contains both tests and subcases, the tests must come first in the
document stream.

### Test

The `test` type indicates a test procedure. A unit MUST have a `status` with
one of five possible values: `pass`, `fail`, `error`, `omit` or `todo`.
Unit documents vary somewhat based on the status. But they all share
common fields. 

Here is an example of a passing unit document.

    ---
    type: test
    subtype: step
    status: pass
    setup: foo instance
    label: multiples of two
    expected: 2
    returned: 2
    file: test/test_foo.rb
    line: 45
    source: ok 1, 2
    snippet:
      - 44: ok 0,0
      - 45: ok 1,2
      - 46: ok 2,4
    coverage:
      file: lib/foo.rb
      line: 11..13
      code: Foo#*
    time: 0.01

Besides the `status`, all test documents MUST have a `label`.

A test document MAY provide a `setup` field, which is used to describe
the setup for the unit test.

Tests SHOULD also give an `expected` and `returned` value, if relavent
to the nature of the test. For example, the most common test assertion is
equality, e.g. <code>assert_equal(4,3)</code>, so `expected` would be `3` and
`returned` woudl be `4`. Although desirable this can be a difficult piece
of information for a test framework to provide, so it is the most often
omitted.

A unit SHOULD also have a `file` and `line` number for source file location.
This is the location of the test definition itself.

A unit SHOULD provide the line of `source` code for the test.
This will be the line of code that `file` and `line` number references.
Unlike `snippet` lines, the source line should be stripped of whitespace.

The `snippet` is like `source` but provides surronding context. It MAY be
a verbatim string, in which case it MUST have an odd number of lines with
the source line in the center. Or, it MAY be an ordered map of verbatim
`- line: source`. Using an ordered map the line numbers may start
and end wherever, but they MUST be consecutive and the source line MUST
be among them.

[EXPERIMENTAL] The `coverage` subsection MAY be provided, in which can have three optional 
fields: `file`, `line` and `code`. Where `file` specifies the source file being
targeted by the test, `line` specifies the line number, range of line
numbers (e.g. `1..4`) or an array of such, and `code` specifices the
language construct being targeted. For example, `code` might be `Foo#bar`
if the test targets the `bar` method of the `Foo` class.

The `time` is the number of seconds that have elapsed since the
the suite start time.

If a test has a status other than `pass` it MUST also provide a `exception`
subsection which is used to describe the nature of the failure, error or
omission.

    ---
    type: test
    subtype: step
    status: fail
    label: multiples of two
    setup: foo instance
    expected: 2
    returned: 1
    file: test/test_foo.rb
    line: 45
    source: ok 1, 2
    snippet:
      - 44: ok 0,0
      - 45: ok 1,2
      - 46: ok 2,4
    coverage:
      file: lib/foo.rb
      line: 11..13
      code: Foo#*
    exception:
      message: |
        (assertion fail) must_equal
        1
        2
      file: test/test_foo.rb
      line: 50
      source: 1.must_equal == v
      snippet:
        - 49: v = 2
        - 50: 1.must_equal == v
        - 51: ''
      backtrace:
        - test/test_foo.rb:50
        - test/test_foo.rb:45
    time: 0.02

The `exception` section MUST give the `message`, describing the nature
of the failure or exception. In this subsection, `file` and `line` indicate
the location in code that triggered the exception or failed assertion.

Like the originating test code, a `source` and code `snippet` SHOULD also
be provided.

It MAY also provide a system `backtrace`.

<blockquote>
Q. Why supply a code snippet when the file and line are already given.
Can't a test reporter just look up the code itself?

A. Of course it can, but if the TAP-Y document is being consumed remotely
it might not have easy access the file being tested. While this may be of
rare use it none the less provides the TAP-Y consumer some view of the
code with having to do additional processing.
</blockquote>

### Note

The `note` type is used to interject a message between tests that
is not tied to a specific unit or case. It has only a few fields.

  ---
  type: note
  text:
    This is an example note.

The note document is simply used to interject any information the 
tester might want to know, but doesn't properly fit elsewhere in the
stream. A note cna appear any where in the document stream prior
to the tally.

### Tally

While a running tally can technically occur anywhere in the document
stream without consequence, it generally incidates the end of a test
suite, which is strictly complete with the end-document-marker (`...`)
appears.

  ---
  type : tally
  time : 0.03
  counts:
    total: 2
    pass : 1
    fail : 1
    error: 0
    omit : 0
    todo : 0
  ...

A tally document MUST provide a counts mapping with the `total` number of
tests (this MUST be same as `count` in the suite document if it was given)
and the totals for each test status. It SHOULD also give the time elapsed
since the suite time.

As mentioned, the test stream ends when a full ellipsis (<code>...</code>)
appears.

As you can see TAP-Y streams provides a great deal of detail. They are not
intended for the end-user, but rather to pipe to a consuming app to process
into a human readable form.


## Glossery of Fields

### count

The `count` field provides the total number of tests being executed. It SHOULD
be given in the header, if possible, and it MUST be given in the footer.

### extra

Additional data, not specifucally designated by this sepecification can
placed within an `extra` section of any document without worry that future
versions of the specification will come into conflict with the field name.
The field MUST be a mapping. The key namespace is a free-for-all, so use it
with that in mind.

### file

The `file` field provides the name of the file in which the test is defined,
or where th test failed/errored.

### line

The `line` field provides the line number of the file on which the
definition of the test begins, or is the line number of where the 
test failed/errored.

### exception

A subsection used to sepcify the nature of a non-passing test.

### message

For tests without a `pass` status, the message provides the explination
for the failure or error. Usually this is just the error message produced by
the underlying exception. The `pass` type can have the message field too,
but it will generally be ignored by TAP consumers.

### snippet

The `snippet` field is either a verbatim string or an ordered mapping of line
number mapped to the source code for that line. While `snippet` is
like `source` it also contains extra lines of code before and after the
test `line` for context.

If `snippet` is a string it MUST consist an odd number of lines, the same
number before and after the source line in the center, unless the line occurs
at the begining or the end of the file. The number of lines before and after is
arbitrary and up to the producer, but should be the same on either side. Three
to five is generally enough.

### source

The `source` field is a verbatim copy of the source code that defines the test.
This may be just the first line of the definition. In classic TAP this
is called `raw_test`.

### start

The suite decument provides date/time information for when a suite of tests
began being tests. The filed MUSTbe in ISO standard format `YYYY-MM-DD HH:MM:SS`.

### status

The `status` field designates the status of a test document. Valid values
are `pass`, `fail`, `error`, `omit` and `todo`.

In comparison to the classic TAP format, `pass` is equivalent to `ok` and 
`fail` and `error` are akin to `not ok`, where `fail` is "not ok" with regards
to a test assertion and `error` is "not ok" becuase of a raised coding error.

Tests with an `omit` status do not need to be provided in the document stream,
so this status might not appear often in practice. But if a producer chooses to
do so this status simply means the test is purposefully being disregarded for
some reason. The `exception` subsection is used to clarify that reason.

On the other hand, `todo` means the test will be used in the future
but implementation has not been completed. It serves as reminder to developers
to write a missing test.

### counts

The footer MUST provide counts for all status categories and the total.
This is like `count` in the suite entry but broken down into status groups.

### time

The tests and the footer SHOULD have the `time` elapsed since starting the 
tests given in number of seconds.

### type

Each document MUST have a *type*. Valid types are `suite`, `tally`, `case`,
`test` and `note`.

The `suite` type can only occur once, at the start of the stream. All other
types may occur repeatedly in between, although the `tally` type will
generally only occur at the end of a stream.

The `case` type marks the start of a testcase. All `test` (and `note`) 
documents following it are considered a part of the case until a new case
document occurs with the same level.

