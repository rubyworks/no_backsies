--- !ruby/object:Gem::Specification 
name: no_backsies
version: !ruby/object:Gem::Version 
  hash: 23
  prerelease: false
  segments: 
  - 0
  - 2
  - 0
  version: 0.2.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-04-29 00:00:00 -04:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: syckle
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: qed
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id002
description: |-
  NoBackies is a callback layer built on top of Ruby's built-in callback
  methods. It makes it possible to add new callbacks very easily, without
  having to fuss with more nuanced issues of defining and redefining callback
  methods.
email: transfire@gmail.com
executables: []

extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- lib/no_backsies.rb
- qed/01_example.rdoc
- qed/02_express.rdoc
- qed/03_options.rdoc
- qed/applique/no_backsies.rb
has_rdoc: true
homepage: http://rubyworks.github.com/nobacksies
licenses: []

post_install_message: 
rdoc_options: 
- --title
- NoBacksies API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: no_backsies
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Better handling of Ruby callbacks
test_files: []

