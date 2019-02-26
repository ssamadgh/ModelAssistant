Pod::Spec.new do |s|

#
	s.name = 'ModelAssistant'
	
	s.version = '1.0.8.2'
	s.license = { :type => "MIT", :file => 'LICENSE' }
	s.summary = 'A Mediator Between Model (or Server) and View'

	s.homepage = 'https://github.com/ssamadgh/ModelAssistant.git'
	s.author = { 'Seyed Samad Gholamzadeh' => 'ssamadgh@gmail.com' }
	s.source = { :git => 'https://github.com/ssamadgh/ModelAssistant.git', :tag => s.version }
 	 s.documentation_url = 'https://ssamadgh.github.io/ModelAssistant/'
	
	s.platform = :ios
	s.ios.deployment_target = '10.0'

	s.source_files = 'Source/**/*.swift'
	s.swift_version = '4.2'
end
