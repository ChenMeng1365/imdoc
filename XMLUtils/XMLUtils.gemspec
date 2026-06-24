


Gem::Specification.new do |spec|
  spec.name          = "XMLUtils"
  spec.version       = '2.0.0'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{doc-tool}
  spec.description   = %q{XMLUtils is a basic doc tool for XML Modeling}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'XMLUtils/XMLUtils',
  ].map{|file|"#{file}.rb"}

  spec.require_paths = ["."]
  spec.add_runtime_dependency 'rexml',  ">= 3.0.0"
end