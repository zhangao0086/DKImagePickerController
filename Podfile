source "https://github.com/CocoaPods/Specs.git"
platform :ios, "8.0"

def common_pods
  #develop local pods
  #pod "XXXX", :path =>"xxxx"
  #Businness
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'iRate', :git => "https://github.com/nicklockwood/iRate.git"

# macro / core helpers
  pod "BlocksKit"
  pod "TBMacros"
  pod "Bolts"
  pod "MustOverride"
  pod "ReflectableEnum"
# pod "dyci", :git => "https://github.com/DyCI/dyci-main.git", :configurations => ["Debug"], :branch => "master"
  pod "dyci", :git => "https://github.com/metasmile/dyci-main.git", :configurations => ["Debug"], :branch => "master"

# system
  pod "Reachability"
  pod "DeviceUtil", :git => "https://github.com/InderKumarRathore/DeviceUtil.git"
# pod "iVersion"
# pod "CargoBay"

# data
  pod "PINCache"
#pod "FastImageCache
  pod "FXNotifications"
  pod "M13OrderedDictionary"
  pod "ObjectiveSugar"
  pod "PAPreferences"
  pod "Block-KVO", :git => "https://github.com/iMartinKiss/Block-KVO.git"
# pod "FormatterKit"
  pod "AFNetworking", "~> 3.0"
#pod "NotificationController"
#pod "FastCoding"
#pod "YOLOKit"
  pod "FCFileManager"
  pod "Realm"

# media
  pod "GPUImage", :podspec => "./Podspec/GPUImage.podspec"
  pod "SoundManager"
# pod "UIImage+PDF"
  pod "SVGKit", :git=> "https://github.com/SVGKit/SVGKit.git", :branch => "2.x"
  pod "NSGIF2", :path => "~/Documents/NSGIF", :branch => "master", :commit => "HEAD"
  # pod "NSGIF2"

# social / service io
#pod "ShareKit" # BUT, watching continue : https://github.com/ShareKit/ShareKit
# pod "InstagramKit", :git=> "https://github.com/shyambhat/InstagramKit"
  pod "LineKit"
  pod "KikAPI"
  pod "FBSDKCoreKit"
  pod "FBSDKLoginKit"
  pod "FBSDKShareKit"
  pod "FBSDKMessengerShareKit"
  pod "TOWebViewController"#, :path => '~/Documents/TOWebViewController'
  pod "TMTumblrSDK", :subspecs => ["Core", "APIClient", "AppClient"], :git => "https://github.com/VidMob/TMTumblrSDK.git"
#https://github.com/nst/STTwitter

#animation
  pod "pop"
  pod "POP+MCAnimate"
# pod "JHChainableAnimations"
# pod 'DGActivityIndicatorView'

# ui / views
# pod "AsyncDisplayKit"
  pod "M13ProgressSuite"
  pod "iCarousel"
  pod "BCMeshTransformView"
  pod "MTGeometry"
  # pod "NHBalancedFlowLayout", :git => "https://github.com/graetzer/NHBalancedFlowLayout"
  pod "NHBalancedFlowLayout", :git => "https://github.com/metasmile/NHBalancedFlowLayout"
  pod "WCFastCell"
  pod "AGGeometryKit"
  pod "AGGeometryKit+POP"
  pod "MMMaterialDesignSpinner"
  pod "SCViewShaker", "~> 1.0"
  pod "UIAlertController+Blocks"
  pod "UIView+Positioning"
  pod "NGAParallaxMotion"
  pod "M13BadgeView"
# pod "UIView+BooleanAnimations"
  pod "TTTAttributedLabel"
# pod "BOString"
# pod "spacetime"
  pod "RMActionController"
  pod "JVFloatLabeledTextField"

# colors
  pod "ChameleonFramework"
# pod "Colours"
  pod "UIColor+BFPaperColors"

# image
  pod "NYXImagesKit", :git=> "https://github.com/metasmile/NYXImagesKit.git", :commit => 'c8a67d6' # https://github.com/Nyx0uf/NYXImagesKit
# pod "FXBlurView", :git=> "https://github.com/nicklockwood/FXBlurView.git", :commit => 'HEAD'
# pod "FaceAwareFill" #reference with : https://github.com/croath/UIImageView-BetterFace/tree/master/bf/bf/BetterFaceClass
  pod "SDWebImage"
  pod "DFImageManager"
  pod 'DFImageManager/GIF' #https://github.com/Flipboard/FLAnimatedImage/pull/117

#location/metadata/exif
  pod "INTULocationManager"
  pod "GusUtils"
  pod "BGUtilities"
end

target 'giff' do
  # In-App purchase
  pod 'RMStore', '~> 0.7'
  pod 'RMStore/NSUserDefaultsPersistence'
  common_pods
end
