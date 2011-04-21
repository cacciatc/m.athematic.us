require 'rubygems'
require 'redis'

module EarthToRedis
  def self.ask_redis_about(this)
    redis = Redis.new
    redis.get(this)
  end
  def self.solve_it!(expression)
    "not implemented yet..."
  end
  def self.solve(expression)
    ask_redis_about(expression) || solve_it!(expression)
  end
end