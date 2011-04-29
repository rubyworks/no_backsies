--- 
spec_version: 1.0.0
name: no_backsies
title: NoBacksies
requires: 
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
resources: 
  code: http://github.com/rubyworks/nobacksies
  mail: http://groups.google.com/group/rubyworks-mailinglist
  home: http://rubyworks.github.com/nobacksies
version: 0.1.0
manifest: MANIFEST
summary: Better handling of Ruby callbacks
authors: 
- Thomas Sawyer
organization: Rubyworks
description: |-
  NoBackies is a callback layer built on top of Ruby's built-in callback
  methods. It makes it possible to add new callbacks very easily, without
  having to fuss with more nuanced issues of defining and redefining callback
  methods.
created: "2011-04-29"
