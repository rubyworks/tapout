require 'tapout'

When 'Using the following TAP-Y sample' do |text|
  @tapy = text
end

When '(((\w+))) reporter should run without error' do |format|
  $stdin  = StringIO.new(@tapy)
  $stdout = StringIO.new(out = '')

  Tapout.cli(format)
end

