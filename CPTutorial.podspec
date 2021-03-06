Pod::Spec.new do |s|


  s.name         = "CPTutorial"
  s.version      = "0.1.4"
  s.summary      = "An extremely easy and modular tutorial system for teaching how to use iOS apps."

  s.description  = <<-DESC
                  Compatible with both Interface Builder and pure programming based projects,
                  CPTutorial is a quick but effective way to add tutorials to your application.
                  CPTutorial takes most of the hard work, leaving the ease of tutorial creation
                  to your hands.
                   DESC

  s.homepage     = "https://github.com/can16358p/CPTutorial"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "can16358p" => "can@canpoyrazoglu.com" }

  s.social_media_url   = "http://twitter.com/can16358p"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/can16358p/CPTutorial.git", :tag => "v0.1.4" }

  s.source_files  = "*.{h,m}"

  s.requires_arc = true

end
