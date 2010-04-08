$: << File.join(File.dirname(__FILE__),"lib")

CLEAN_FILES = FileList.new("dummy","gotasks*.gem")
TEST_DEPENDENCIES = ["pkg/dummypkg.a"]

require "gotasks"

task :default => "all"

desc "builds the gem"
task :gem do
  system %(gem build gotasks.gemspec)
end


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
