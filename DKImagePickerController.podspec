Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "4.3.2"
  s.summary       = "DKImagePickerController is a highly customizable, pure-Swift library."
  s.homepage      = "https://github.com/zhangao0086/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKImagePickerController.git", 
                     :tag => s.version.to_s }
  
  s.requires_arc  = true
  s.swift_version = ['4.2', '5']

  s.subspec 'Core' do |core|
    core.dependency 'DKImagePickerController/ImageDataManager'
    core.dependency 'DKImagePickerController/Resource'

    core.frameworks    = "Foundation", "UIKit", "Photos"

    core.source_files = "Sources/DKImagePickerController/*.{h,swift}", "Sources/DKImagePickerController/View/**/*.swift"
  end

  s.subspec 'ImageDataManager' do |image|
    image.source_files = "Sources/DKImageDataManager/**/*.swift"
  end

  s.subspec 'Resource' do |resource|
    resource.resource_bundle = { "DKImagePickerController" => "Sources/DKImagePickerController/Resource/Resources/*" }

    resource.source_files = "Sources/DKImagePickerController/Resource/DKImagePickerControllerResource.swift"
  end

  s.subspec 'PhotoGallery' do |gallery|
    gallery.dependency 'DKImagePickerController/Core'
    gallery.dependency 'DKPhotoGallery'

    gallery.source_files = "Sources/Extensions/DKImageExtensionGallery.swift"
  end

  s.subspec 'Camera' do |camera|
    camera.dependency 'DKImagePickerController/Core'
    camera.dependency 'DKCamera'

    camera.source_files = "Sources/Extensions/DKImageExtensionCamera.swift"
  end

  s.subspec 'InlineCamera' do |inlineCamera|
    inlineCamera.dependency 'DKImagePickerController/Core'
    inlineCamera.dependency 'DKCamera'

    inlineCamera.source_files = "Sources/Extensions/DKImageExtensionInlineCamera.swift"
  end

  s.subspec 'PhotoEditor' do |photoEditor|
    photoEditor.dependency 'DKImagePickerController/Core'
    photoEditor.dependency 'CropViewController', '~> 2.5'

    photoEditor.source_files = "Sources/Extensions/DKImageExtensionPhotoCropper.swift"
  end

end
