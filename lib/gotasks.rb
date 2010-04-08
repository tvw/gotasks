['GOROOT','GOARCH','GOBIN','GOOS'].each do |envvar|
  unless self.class.const_defined?(envvar)
    if ENV.has_key?(envvar)
      self.class.const_set(envvar, ENV[envvar])
    else
      raise "#{envvar} not defined"
    end
  end
end

if GOARCH=="amd64"
  GO_OBJ_EXT=".6"
  GO_COMPILER="6g"
  GO_LINKER="6l"
elsif GOARCH=="386"
  GO_OBJ_EXT=".8"
  GO_COMPILER="8g"
  GO_LINKER="8l"
elsif GOARCH=="arm"
  GO_OBJ_EXT=".5"
  GO_COMPILER="5g"
  GO_LINKER="5l"
else
  raise "gotasks: architecture #{GOARCH} not supportedh"
end

GOPKG = ['.','pkg','test'] unless self.class.const_defined?('GOPKG')
TEST_DEPENDENCIES = [] unless self.class.const_defined?('TEST_DEPENDENCIES')
TEST_FILES = FileList.new('test/**/*_test.go')


class GoTestFile
  attr_reader :filename, :package, :benchmarks, :tests

  def initialize(filename)
    @filename = filename

    @tests = []
    @benchmarks = []
    @package = nil
    IO.popen("gofmt -comments=false \"#{@filename}\"", 'r') do |f|
      f.each_line do |line|
        if line =~ /^\s*package\s+(.*)\s*$/
          @package = $1 
        elsif line =~ /^\s*func\s+(Test.+)\s*\(/
          @tests << $1
        elsif line =~ /^\s*func\s+(Benchmark.+)\s*\(/
          @benchmarks << $1
        end
      end
    end
  end

  def tests?
    tests.length > 0
  end

  def package?
    !package.nil?
  end

  def benchmarks?
    benchmarks.length > 0
  end

  def testfile
    gofile = []
    gofile << "package main"
    gofile << "import \"#{package}\""
    gofile << "import \"testing\""

    gofile << ''
    gofile << "var tests = []testing.Test {"
    @tests.each do |test|
      gofile << "\ttesting.Test{ \"#{package}.#{test}\", #{package}.#{test} },"
    end
    gofile << "}"

    gofile << ''
    gofile << "var benchmarks = []testing.Benchmark {"
    @benchmarks.each do |benchmark|
      gofile << "\ttesting.Benchmark{ \"#{package}.#{benchmark}\", #{package}.#{benchmark} },"
    end
    gofile << "}"

    gofile << ''
    gofile << 'func main() {'
    gofile << '	testing.Main(tests);'
    gofile << '	testing.RunBenchmarks(benchmarks)'
    gofile << '}'

    gofile.join("\n")
  end

  def runner
    @filename.ext('') + "runner.go"
  end

  def save(outfile = runner)
    File.open(outfile, "w") do |f|
      f.puts testfile
    end
    self
  end

end


def gocompile(out, source)
  sh "#{GO_COMPILER} -I#{GOPKG.join(" -I")} -o #{out} #{source}"
end

def golink(out, source)
  sh "#{GO_LINKER} -L#{GOPKG.join(" -L")} -o #{out} #{source}"
end

def gopack(archive, *files)
  mkdir_p File.dirname(archive) unless File.exists?(File.dirname(archive))
  sh "gopack grc #{archive} #{files.join(' ')}"
end

def runtest(test)
  result = nil
  IO.popen("#{test}", "r") do |f|
    result = f.readlines.join('')
  end

  unless $?.to_i == 0 and result =~ /^\s*PASS\s*$/
    puts "#{test}:"
    IO.popen("#{test}", "r") do |f|
      puts f.readlines
    end
    return false
  end

  return true
end


rule GO_OBJ_EXT => [".go"] do |t|
  gocompile t.name, t.source
end

# Link Go-Files
rule /^[a-z0-9]+$/ => [GO_OBJ_EXT] do |t|
  golink t.name, t.prerequisites.first
end

# Create a Package
rule '.a' => [GO_OBJ_EXT] do |t|
  gopack t.name, *t.prerequisites
end

TEST_FILES.each do |test|
  file test.ext('').gsub(/^test/,'testrun') => test.ext(GO_OBJ_EXT).gsub(/^test/,'testrun') do |t|
    golink t.name, t.prerequisites.last
  end
  
  file test.gsub(/^test/,'testrun') => test.ext(GO_OBJ_EXT) do |t|
    GoTestFile.new(t.prerequisites.last.ext('.go')).save(t.name)
  end
end


desc "run all tests"
task :test => "test:all"

namespace :test do
  desc "clean tests"
  task :clean do
    FileList.new('./testrun', 'test/**/*.[6]').each do |f|
      rm_rf f if File.exists?(f)
    end
  end

  task :all => ['testdir'] + TEST_DEPENDENCIES + TEST_FILES.ext('').collect{|f| f.gsub(/^test/,'testrun') } do
    passed = 0
    failed = 0
    TEST_FILES.each do |test|
      if runtest("#{test.ext('').gsub(/^test/,'testrun')}")
        passed+=1
      else
        failed+=1
      end
    end
    puts "#{passed+failed} Tests: #{passed} OK / #{failed} FAILED"
  end

  task :testdir do
    TEST_FILES.each do |test|
      dirname = File.dirname(test.ext('').gsub(/^test/,'testrun'))
      mkdir_p dirname unless File.exists?(dirname)
    end    
  end
end


desc "remove all generated files"
task :clean => "test:clean" do
  (CLEAN_FILES + FileList.new('**/*.[6a]','./pkg')).each do |f|
    if File.exists?(f)
      if File.directory?(f)
        rm_rf f
      else
        rm_f f
      end
    end
  end
end
