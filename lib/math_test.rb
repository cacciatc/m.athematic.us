require 'rubygems'
#require 'redis'
require 'sinatra'
require File.dirname(__FILE__) + '/mr-proxy'
  
module EarthToRedis
  def self.ask_redis_about(this,redis)
    #redis.get(this)
  end
  def self.solve_it!(expression,redis)
    s = MrProxy.what_should_i_do(expression).well_do_it!
    str = "<div class=\"answer\"> <h1 align=\"center\">#{s.work.last[:expr]}</h1></div><div class=\"work\" align=\"center\"><table cellpadding=\"10\">"
    str = s.work.inject(str) do |s,e|
      s += "<tr>
          <td>#{e[:expr]}</td>
          <td>#{e[:note]}</td>
        </tr>"
    end
    str += "</table></div>"
  end
  def self.solve(expression)
    #redis = Redis.new
    redis = :dummy
    ask_redis_about(expression,redis) || solve_it!(expression,redis)
  end
end

configure do
end

get '/' do
  erb :index
end

post '/' do
  p = params['post']
  #redirect "/expr/#{EarthToRedis.solve(p['expr'])}"
  @s = EarthToRedis.solve(p['expr'])
  erb :expr
end

get '/expr/:id' do |expr_id|
  erb :expr
end
