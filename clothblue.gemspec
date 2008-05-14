Gem::Specification.new do |s|
  s.name = "ClothBlue"
  s.version = "0.2.1"
  s.date = "Time.now"
  s.summary = "HTML to Markdown converter"
  s.email = "cpjolicoeur@gmail.com"
  s.homepage = "http://github.com/cpjolicoeur/clothblue"
  s.description = "ClothBlue is BlueCloth's evil twin.  It converts existing HTML into Markdown format for use with BlueCloth."
  s.has_rdoc = true
  s.authors = ["Craig P Jolicoeur"]
  s.files = ["README", "TODO", "clothblue.gemspec", "lib/clothblue.rb", "lib/README.rdoc", "test/README", "test/test_entities.rb", "test/test_formatting.rb", "test/test_headings.rb", "test/test_lists.rb", "test/test_structure.rb", "test/test_tables.rb"]
  s.test_files = ["test/test_entities.rb", "test/test_formatting.rb", "test/test_headings.rb", "test/test_lists.rb", "test/test_structure.rb", "test/test_tables.rb"]
  s.rdoc_options = ["--main", "lib/README.rdoc"]
end