

Pod::Spec.new do |s|



  s.name         = "eeuiAudio"
  s.version      = "1.0.0"
  s.summary      = "eeui plugin."
  s.description  = <<-DESC
                    eeui plugin.
                   DESC

  s.homepage     = "https://eeui.app"
  s.license      = "MIT"
  s.author             = { "kuaifan" => "aipaw@live.cn" }
  s.source =  { :path => '.' }
  s.source_files  = "eeuiAudio", "**/**/*.{h,m,mm,c}"
  s.exclude_files = "Source/Exclude"
  s.resources = 'eeuiAudio/resources/*.*'
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.dependency 'WeexSDK'
  s.dependency 'eeui'
  s.dependency 'WeexPluginLoader', '~> 0.0.1.9.1'
  s.dependency 'FreeStreamer', '~> 3.9.3'

end
