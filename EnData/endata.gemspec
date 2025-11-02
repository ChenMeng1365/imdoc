


Gem::Specification.new do |spec|
  spec.name          = "endata"
  spec.version       = '0.2.1'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{doc-tool}
  spec.description   = %q{endata is a doc tool of inline document}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'EnData/endata',
    'EnData/endata-app',
    'EnData/api-app', # no must
  ].map{|file|"#{file}.rb"}

  spec.require_paths = ["."]
end