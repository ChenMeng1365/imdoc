


Gem::Specification.new do |spec|
  spec.name          = "casetdown"
  spec.version       = '0.9.1'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com"]

  spec.summary       = %q{test-tool}
  spec.description   = %q{casetdown is a test tool of markdown document}
  spec.homepage      = %q{http://127.0.0.1}
  spec.files         = [
    'CasetDown/casetdown',
    'CasetDown/casetter',
    'CasetDown/casetdoc',
    'CasetDown/casetcode',
    'CasetDown/casetable',
    'EnData/endata',
    'EnData/endata-app',
    'EnData/api-app', # Special Customize
    'XMLUtils/XmlUtils',
    'TextUtils/text_abstract',
    'TextUtils/text_absparser',
    'TextUtils/text_mind',
    'Tabot/newtab',
    'Tabot/simtab',
    'TinText/tum',
    'TinText/cache',
    'TinText/tin_text',
    'TinText/tintext'
  ].map{|file|"#{file}.rb"}

  spec.bindir        = "CasetDown/bin"
  spec.executables   = ["cm","cml"]

  spec.require_paths = ["."]
end