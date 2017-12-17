Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "4.0.0"
  s.summary       = "Image Picker Controller by Swift3."
  s.homepage      = "https://github.com/zhangao0086/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKImagePickerController.git", 
                     :tag => s.version.to_s }

  s.resource      = "DKImagePickerController/DKImagePickerController.bundle"
  s.frameworks    = "Foundation", "UIKit", "Photos"
  s.requires_arc  = true

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.default_subspecs = 'Full'

  s.subspec 'Core' do |core|
    core.dependency 'DKImagePickerController/ImageDataManager'

    core.source_files = "DKImagePickerController/**/*.{h,swift}"

  end

  s.subspec 'ImageDataManager' do |image|

    image.ios.source_files = "DKImageDataManager/**/*.swift"
  end

  s.subspec 'PhotoGallery' do |gallery|
    gallery.dependency 'DKImagePickerController/Core'
    gallery.dependency 'DKPhotoGallery', '0.0.1'

    gallery.ios.source_files = "Extensions/DKImageExtensionGallery.swift"
  end

  s.subspec 'Camera' do |camera|
    camera.dependency 'DKImagePickerController/Core'
    camera.dependency 'DKCamera', '1.5.1'

    camera.ios.source_files = "Extensions/DKImageExtensionCamera.swift"
  end

  s.subspec 'InlineCamera' do |inlineCamera|
    inlineCamera.dependency 'DKImagePickerController/Core'
    inlineCamera.dependency 'DKCamera', '1.5.1'

    inlineCamera.ios.source_files = "Extensions/DKImageExtensionInlineCamera.swift"
  end

  s.subspec 'PhotoEditor' do |photoEditor|
    photoEditor.dependency 'DKImagePickerController/Core'
    photoEditor.dependency 'CLImageEditor', '0.2.0'

    photoEditor.ios.source_files = "Extensions/DKImageExtensionPhotoEditor.swift"
  end

  s.subspec 'Full' do |full|
    full.dependency 'DKImagePickerController/Core'
    full.dependency 'DKImagePickerController/Camera'
    full.dependency 'DKImagePickerController/InlineCamera'
    full.dependency 'DKImagePickerController/PhotoGallery'
    full.dependency 'DKImagePickerController/PhotoEditor'
  end

end
