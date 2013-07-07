platform :osx, 10.8

target :Optique, :exclusive => true do
  pod 'INAppStoreWindow', :head 
  pod 'CDEvents', '~> 1.2.0'
  pod 'NSHash', '~> 1.0.1'
  pod 'BlocksKit', '~> 1.8.2'
  pod 'OEGridView', :path => '~/code/OEGridView'
end

target :Flickr, :exclusive => true do
  link_with 'Exposure'
  pod 'AFNetworking', '~> 1.3.1'
  pod 'gtm-oauth', '~> 0.0.1'
end
