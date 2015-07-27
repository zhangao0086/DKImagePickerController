Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "1.0.4"
  s.summary       = "This is a very simple Image Picker Controller by Swift."
  s.homepage      = "https://github.com/zhangao0086/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKImagePickerController.git", 
                     :tag => s.version.to_s }
  s.source_files  = "DKImagePickerController/*.swift"
  s.resource      = "DKImagePickerController/*.png"
  s.frameworks    = "Foundation", "UIKit", "AssetsLibrary"
  s.requires_arc  = true
end
