


Gem::Specification.new do |spec|
  spec.name          = "tabot"
  spec.version       = '0.4.2'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{table bot}
  spec.description   = %q{table bot}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'Tabot/ExcelBot',
    'Tabot/RooBot',
    'Tabot/newtab',
    'Tabot/simtab',
    'Tabot/tabot'
  ].map{|file|"#{file}.rb"}

  # spec.bindir        = "."
  # spec.executables   = ["."]

  spec.require_paths = ["."]
end