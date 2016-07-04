Pod::Spec.new do |s|
  s.name     = 'TOWebViewController'
  s.version  = '2.2.6'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'An inline browser view controller that allows users to view and navigate web pages from within an app.'
  s.homepage = 'https://github.com/TimOliver/TOWebViewController'
  s.author   = 'Tim Oliver'
  s.source   = { :git => 'https://github.com/TimOliver/TOWebViewController.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.platform = :ios, '5.1'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.frameworks = 'QuartzCore', 'CoreGraphics'
    core.weak_frameworks = 'Twitter', 'MessageUI'
    core.source_files = 'TOWebViewController/**/*.{h,m}'
    core.resource_bundles = {'TOWebViewControllerLocalizable' => 'TOWebViewController/**/*.lproj'}
  end

  s.subspec '1Password' do |op|
    op.platform = :ios, '8.0'
    op.dependency	'1PasswordExtension'
    op.source_files = 'TOWebViewController/**/*.{h,m}', 'TOWebViewController+1Password/*.{h,m}'
    op.frameworks = 'MobileCoreServices'
  end
end
