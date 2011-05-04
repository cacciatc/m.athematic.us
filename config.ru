require File.dirname(__FILE__) + "/lib/math_test"
set :app_file, File.expand_path(File.dirname(__FILE__) + '/lib/math_test.rb')
set :public,   File.expand_path(File.dirname(__FILE__) + '/lib/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/lib/views')
set :env,      :production
disable :run, :reload
run Sinatra::Application