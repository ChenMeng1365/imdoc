


Gem::Specification.new do |spec|
  spec.name          = "tintext"
  spec.version       = '1.1.2'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{text-tool}
  spec.description   = %q{tintext is a text tool of template document}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'TinText/tum',
    'TinText/cache',
    'TinText/tin_text',
    'TinText/tintext'
  ].map{|file|"#{file}.rb"}

  # spec.bindir        = "TinText/bin"
  # spec.executables   = ["tintext"]

  spec.require_paths = ["."]
end