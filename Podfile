platform :osx, 10.8

target :Optique, :exclusive => false do
  pod 'INAppStoreWindow', :head 
  pod 'NSHash', '~> 1.0.1'
  pod 'BlocksKit', '~> 1.8.2'
  pod 'OEGridView', :path => '~/code/OEGridView'
  pod 'CNBaseView', '~> 1.0.11'
  pod 'KBButton', :git => 'git@github.com:i386/KBButton.git'
end

target :Exposure, :exclusive => true do
  pod 'BlocksKit', '~> 1.8.2'
end

target :Local, :exclusive => true do
  pod 'CDEvents', '~> 1.2.0'
  pod 'BlocksKit', '~> 1.8.2'
end

target :Flickr, :exclusive => true do
  pod 'AFNetworking', '~> 1.3.1'
  pod 'gtm-oauth', '~> 0.0.1'
end
