Pod::Spec.new do |s|

  s.name         = 'ModelAssistant'
  s.version      = '0.9.0'
  s.license = { :type => "MIT", :file => 'LICENSE' }  
  s.summary      = 'A Mediator Between Model (or Server) and View'

  s.description  = <<-DESC
  This library is a Controller in MVC design pattern.
  It is a Presenter in MVP design pattern.
  It is a ViewModel in MVVM design pattern.
  It is a Interactor in Viper design pattern.
                   DESC

  s.homepage     = 'https://github.com/ssamadgh/ModelAssistant.git'
  s.author             = { 'Seyed Samad Gholamzadeh' => 'ssamadgh@gmail.com' }
  s.source       = { :git => 'https://github.com/ssamadgh/ModelAssistant.git', :tag => s.version }

  s.platform = :ios, '8.0'
  
  s.source_files = 'Source/**/*.swift'

end
