Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "3.8.1"
  s.summary       = "Image Picker Controller by Swift4."
  s.homepage      = "https://github.com/zhangao0086/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKImagePickerController.git", 
                     :tag => s.version.to_s }
  s.source_files  = "DKImagePickerController/**/*.{h,swift}"

  s.resource      = "DKImagePickerController/DKImagePickerController.bundle"
  s.frameworks    = "Foundation", "UIKit", "Photos"
  s.requires_arc  = true

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.subspec 'Camera' do |camera|

    camera.ios.source_files = "DKCamera/DKCamera.swift", "DKCamera/DKCameraResource.swift"
    camera.resource = "DKCamera/DKCameraResource.bundle"
  end

  s.subspec 'ImageManager' do |image|

    image.ios.source_files = "DKImageManager/**/*.swift"
  end

end
