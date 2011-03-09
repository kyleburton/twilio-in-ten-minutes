PKG_VERSION = '0.0.1'
PKG_FILES = Dir['lib/**/*.rb', 'spec/**/*.rb']
 
$spec = Gem::Specification.new do |s|
  s.name = 'twml'
  s.version = PKG_VERSION
  s.summary = "Twilio Markup Language Ruby DSL"
  s.description = <<EOS
Twilio Markup Language DSL as a support module.

    require 'twml'
    TWML.response do
      say "Welcome to my Twilio IVR"
      gather(:action => '/user_chose_option', :digits => 1) do 
        say "Press 1 for option A"
        say "Press 2 for option B"
      end
    end

EOS
  
  s.files = PKG_FILES.to_a
  s.files << "README.textile"
 
  s.has_rdoc = false
  s.authors = ["Kyle Burton"]
  s.email = "kyle.burton@gmail.com"
  s.homepage = "https://github.com/kyleburton/twilio-in-ten-minutes"
end
 
