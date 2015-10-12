MRuby::Gem::Specification.new('mruby-mrack') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Jared Breeden'
  spec.summary = 'A small, rack-like, multithreaded server for MRuby'
  spec.cc.flags << "-std=c++11"
end
