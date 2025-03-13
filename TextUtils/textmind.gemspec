


Gem::Specification.new do |spec|
  spec.name          = "textmind"
  spec.version       = '0.3.5 '
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{text-tool}
  spec.description   = %q{text_abstract is a text tool of complex text document}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'TextUtils/text_abstract',
    'TextUtils/text_absparser',
    'TextUtils/text_mind',
    'TextUtils/textmind'
  ].map{|file|"#{file}.rb"}

  spec.bindir        = "TextUtils/bin"
  spec.executables   = ["tm"]

  spec.require_paths = ["."]
end