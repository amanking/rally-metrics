Gem::Specification.new do |s|
  s.name = 'rally_client'
  s.version = '0.0.1'
  s.date = '2013-05-07'
  s.summary = 'Client to fetch info from Rally'
  s.authors = ['Tushar Madhukar']
  s.files = %x{git ls-files}.split("\n") - %w[.gitignore Rakefile ]
  s.test_files = s.files.select { |p| p =~ /^spec\/.*.rb/ }

  s.add_dependency "rally_api", "~> 0.9.11"
  s.add_dependency "builder", ">= 3.2.0"
end