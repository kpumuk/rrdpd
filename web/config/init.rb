# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'a376d3a349b5c50d523bf7ae479303f45f18a220'  # required for cookie session store
  c[:session_id_key] = '_rrdpd_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
end
 
Merb::BootLoader.after_app_loads do
  Configuration.load("config/rrdpd-web.conf")
  Merb.add_mime_type(:png, :to_png, %w[image/png])
end
