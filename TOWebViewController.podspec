Pod::Spec.new do |s|
  s.name     = 'TOWebViewController'
  s.version  = '2.2'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'An inline browser view controller that allows users to view and navigate web pages from within an app.'
  s.homepage = 'https://github.com/TimOliver/TOWebViewController'
  s.author   = 'Tim Oliver'
  s.source   = { :git => 'https://github.com/TimOliver/TOWebViewController.git', :tag => s.version.to_s }
  s.platform = :ios, '5.0'

  s.source_files = 'TOWebViewController/**/*.{h,m}'
  s.resource_bundles = {'TOWebViewControllerLocalizable' => 'TOWebViewController/**/*.lproj'}
  s.requires_arc = true
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    # Base library with no extra dependencies
  end

  spec.subspec '1Password' do |op|
    op.dependency	'1PasswordExtension'
    op.source_files = 'TOWebViewController+1Password/*.{h,m}'
  end
end
