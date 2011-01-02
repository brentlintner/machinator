Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'machinator'
  s.version = '0.1'
  s.summary = 'obfuscate file content and directory structures.'
  s.description = 'obfuscate file content and directory structures'

  s.required_ruby_version = '>= 1.8.6'

  s.author = 'Brent Lintner'
  s.email = 'brent.lintner@gmail.com'
  s.homepage = 'http://github.com/brentlintner/machinator'

  s.files = Dir['bin/*', 'machinator.gemspec', 'README.rdoc', 'lib/**/*'].to_a

  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README.rdoc )
  s.rdoc_options.concat ['--main',  'README.rdoc']

  s.executables = ["machinator"]
  s.require_path = "lib"
end
