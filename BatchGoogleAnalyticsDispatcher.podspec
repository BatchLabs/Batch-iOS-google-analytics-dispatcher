Pod::Spec.new do |s|
  s.name             = 'BatchGoogleAnalyticsDispatcher'
  s.version          = '1.0.1'
  s.summary          = 'Batch.com Events Dispatcher Google Analytics implementation.'

  s.description      = <<-DESC
  A ready-to-go event dispatcher for Google Analytics. Requires the Batch iOS SDK.
                       DESC

  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Batch.com' => 'support@batch.com' }
  s.source           = { :git => 'https://github.com/BatchLabs/Batch-iOS-google-analytics-dispatcher.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.platforms = {
    "ios" => "8.0"
  }

  s.requires_arc = true
  s.static_framework = true
  
  s.dependency 'GoogleAnalytics'
  s.dependency 'Batch', '~> 1.15'

  s.source_files = 'BatchGoogleAnalyticsDispatcher/Classes/**/*'
end
