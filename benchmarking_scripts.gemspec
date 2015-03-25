Gem::Specification.new do |s|
  s.name        = 'benchmarking_scripts'
  s.version     = '0.0.4'
  s.date        = '2013-08-10'
  s.licenses    = ['MIT']
  s.summary     = "Benchmarking Scripts"
  s.description = "Helps to evaluate results of various algorithms"
  s.authors     = ["Katharina Hayer"]
  s.email       = 'katharinaehayer@gmail.com'
  s.files       = Dir.glob("lib/**/*")
  s.homepage    =
    'https://github.com/khayer/benchmarking_scripts'
  s.executables = Dir.glob("bin/**/*").map{|f| File.basename(f)}
end
