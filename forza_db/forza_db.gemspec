# put lib on $LOAD_PATH so require X works absolutely
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "forza_db"
  s.version = "0.0.0"
  s.date = "2019-02-09"
  s.authors = ["Edward Dal Santo"]
  s.email = ["ejds001@gmail.com"]

  s.summary = "Toy DBMS in Ruby"
  s.files = Dir.glob("lib/**/*.rb")
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.16.0"
  s.add_development_dependency "rspec", "~> 3.8.0"
  s.add_development_dependency "pry", "~> 0.12.0"
  s.add_development_dependency 'google-protobuf'
end
