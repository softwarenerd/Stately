Pod::Spec.new do |spec|
  spec.name             = 'Stately'
  spec.version          = '1.00'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/softwarenerd/Stately'
  spec.author           = { 'Brian Lambert' => 'brianlambert@gmail.com' }
  spec.summary          = 'A pure Swift framework for iOS, macOS, watchOS, and tvOS that implements an event-driven finite-state machine.'
  spec.source           = { :git => 'https://github.com/softwarenerd/Stately.git', :tag => 'v1.00' }
  spec.source_files     = 'Stately/Code/*'
  spec.framework        = 'Foundation'
  spec.requires_arc     = true
end