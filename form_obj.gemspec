
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "form_obj/version"

Gem::Specification.new do |spec|
  spec.name          = "form_obj"
  spec.version       = FormObj::VERSION
  spec.authors       = ["Alexander Koltun"]
  spec.email         = ["alexander.koltun@gmail.com"]

  spec.summary       = %q{Simple but powerful form object compatible with Rails form builders.}
  spec.description   = %q{Form Object with simple DSL which allows nested Form Objects and arrays of Form Objects. Form
Object is compatible with Rails form builders, can update its attributes from a hash and serialize them to a hash.
Form Object attributes could be mapped to models attributes and Form Object can be loaded from and saved to models as
well as serialized to a hash which reflects a model. ActiveModel::Errors could be copied from a model to Form Object.}
  spec.homepage      = "https://github.com/akoltun/form_obj"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "typed_array", ">= 1.0.0"
  spec.add_runtime_dependency "activesupport", ">= 3.2"
  spec.add_runtime_dependency "activemodel", ">= 3.2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "actionpack", ">= 3.2"
end
