# Normally we would use rubygems:
# require 'rubygems'
# but when developing gotasks, we use this:
$: << File.join(File.dirname(__FILE__),"lib")


################################################################################
## Example tasks
################################################################################

CLEAN_FILES = FileList.new("dummy","gotasks*.gem")
TEST_DEPENDENCIES = ["pkg/dummypkg.a"]

require "gotasks"
require 'gotasks/version'

task :default => "all"

desc "Generate all files and run tests"
task :all => ["dummy", "test"]


desc "the dummy package"
file "pkg/dummypkg.a" => ["src/pkg/dummypkg1#{GO_OBJ_EXT}", 
                          "src/pkg/dummypkg2#{GO_OBJ_EXT}"] do |t|
  gopack t.name, *t.prerequisites
end


desc "the dummy program"
file "dummy" => ["pkg/dummypkg.a",
                 "src/dummy#{GO_OBJ_EXT}"] do |t|
  golink t.name, t.prerequisites.last
end



################################################################################
## tasks for
################################################################################

namespace :gem do
  desc "builds the gem"
  task :build do
    system %(gem build gotasks.gemspec)
  end

  desc "push gem to RubyGems.org"
  task :push => ["build"] do
    system %(gem push "gotasks-#{GoTasks::VERSION}.gem")
  end
end

