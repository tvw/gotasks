require 'lib/gotasks/version'

Gem::Specification.new do |gem|
  gem.name = 'gotasks'
  gem.version = GoTasks::VERSION
  
  gem.summary = "Rake tasks for go projects."
  gem.description = "Rake tasks and rules for compiling go projects (http://golang.org)"
  
  gem.files = Dir['lib/**/*', 'README*', 'LICENSE*']
  
  gem.add_dependency 'rake', '~> 0.8.7'
  
  gem.email = 'tvw@s4r.de'
  gem.homepage = 'http://github.com/tvw/' + gem.name
  gem.authors = ['Thomas Volkmar Worm']
  
  gem.has_rdoc = true
  gem.rubyforge_project = nil
end
