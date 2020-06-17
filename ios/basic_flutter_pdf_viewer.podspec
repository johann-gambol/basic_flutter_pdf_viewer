#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'basic_flutter_pdf_viewer'
  s.version          = '1.0.1'
  s.summary          = 'A fully functional pdf viewer for both iOS and Android.'
  s.description      = <<-DESC
A fully functional pdf viewer for both iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/johann-gambol/basic_flutter_pdfviewer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Johann Gambol' => 'jo.gambol@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.framework        = 'WebKit'
  
  s.ios.deployment_target = '9.0'
end

