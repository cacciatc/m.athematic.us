require 'rubygems'
require 'redis'
require 'sinatra'
  
  $forms = [
    [/([0-9]+[.]{0,1}[0-9]*)\^([a-z]+)\=([0-9]+[.]{0,1}[0-9]*)/,
    %q{"
      <h1>$#{m[1+1]} = #{Math.log(m[2+1].to_f)/Math.log(m[0+1].to_f)}$</h1>
      <table id=\"work\" cellpadding=\"10\">
        <tr>
          <td>$#{m[0+1]}^#{m[1+1]} = #{m[2+1]}$</td>
          <td>original problem</td>
        </tr>
        <tr>
          <td>$\\log _{#{m[0+1]}} {#{m[2+1]}} = #{m[1+1]}$</td>
          <td>definition of logarithm</td>
        </tr>
        <tr>
          <td>$\\\\frac{\\log{#{m[2+1]}}}{\\log{#{m[0+1]}}} = #{m[1+1]}$</td>
          <td>change of logarithm base</td>
        </tr>
        <tr>
          <td>$#{m[1+1]} = #{Math.log(m[2+1].to_f)/Math.log(m[0+1].to_f)}$</td>
          <td>division</td>
      </table>
    "}],
    [/([0-9]+[.]{0,1}[0-9]*)\+log([0-9]+[.]{0,1}[0-9]*)([a-z]+)\=([0-9]+[.]{0,1}[0-9]*)/,
    %q{"
      <h1>$#{m[3+1]} = \\\\frac{10^(#{m[3+1].to_f - m[0+1].to_f})}{#{m[1+1]}}$</h1>
      <table id=\"work\" cellpadding=\"10\">
        <tr>
          <td>$#{m[0+1]}+\\log{#{m[1+1]}#{m[2+1]}} = #{m[3+1]}$</td>
          <td>original problem</td>
        </tr>
        <tr>
          <td>$\\log {#{m[1+1]}#{m[2+1]}} = #{m[3+1].to_f - m[0+1].to_f}$</td>
          <td>subtraction</td>
        </tr>
        <tr>
          <td>$10^(#{m[3+1].to_f - m[0+1].to_f}) = #{m[1+1]}#{m[2+1]}$</td>
          <td>definition of logarithm</td>
        </tr>
        <tr>
          <td>$#{m[2+1]} = \\\\frac{10^(#{m[3+1].to_f - m[0+1].to_f})}{#{m[1+1]}}$</td>
          <td>division</td>
        </tr>
      </table>
    "}]
  ]
module Logarithm
  def self.try_to_solve(expression)
    $forms.each do |f|
      m = expression.match(f.first)
      if m != nil
        return instance_eval(f.last)
      end
    end
    return expression
  end
end

module EarthToRedis
  def self.ask_redis_about(this,redis)
    redis.get(this)
  end
  def self.solve_it!(expression,redis)
    Logarithm.try_to_solve(expression)
  end
  def self.solve(expression)
    redis = Redis.new
    ask_redis_about(expression,redis) || solve_it!(expression,redis)
  end
end

get '/:expression' do |ex|
  %q{<html><head>
    <script type="text/javascript"
      src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
    </script>
    <script type="text/x-mathjax-config">
      MathJax.Hub.Config({
        extensions: ["tex2jax.js"],
        jax: ["input/TeX","output/HTML-CSS"],
        tex2jax: {inlineMath: [["$","$"],["\\(","\\)"]]}
      });
    </script>
    </head><body><p>
    } + EarthToRedis.solve(URI.unescape(ex)) + %q{</p>
    <div id="graph" style="width:320px;height:300px;border:1px"></div>
  </body>}
end
