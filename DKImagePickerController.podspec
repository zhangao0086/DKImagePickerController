Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "2.3.5"
  s.summary       = "New version! It's a Facebook style Image Picker Controller by Swift."
  s.homepage      = "https://github.com/zhangao0086/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKImagePickerController.git", 
                     :tag => s.version.to_s }
  s.source_files  = "DKImagePickerController/*.swift"
  s.resource      = "DKImagePickerController/DKImagePickerController.bundle"
  s.frameworks    = "Foundation", "UIKit", "AssetsLibrary", "AVFoundation"
  s.requires_arc  = true

  s.subspec 'Camera' do |ss|

    ss.ios.source_files = "DKCamera/DKCamera.swift"
    ss.resource = "DKCamera/DKCameraResource.bundle"
  end

end
