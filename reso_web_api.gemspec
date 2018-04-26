
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "reso_web_api/version"

Gem::Specification.new do |spec|
  spec.name          = "reso_web_api"
  spec.version       = ResoWebApi::VERSION
  spec.authors       = ["Christoph Wagner"]
  spec.email         = ["christoph@wrstudios.com"]

  spec.summary       = %q{RESO Web API for Ruby}
  spec.description   = %q{Allows communication with MLS systems conforming to the RESO Web API standard}
  spec.homepage      = "https://github.com/wrstudios/reso_web_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.15.0'
  spec.add_dependency 'odata4', '~> 0.8.1'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
