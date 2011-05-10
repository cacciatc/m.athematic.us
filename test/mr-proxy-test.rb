require File.dirname(__FILE__) + '/../lib/mr-proxy'
require 'rspec'

describe MrProxy do
  it "should simplify polynomials" do
    this = MrProxy.what_should_i_do('simplify 10x-(2x+(13-4x)-(11-3x))+(2x+5)')
    this.well_do_it!.answer.should == '11x + 3'
  end
  it "should solve linear equations" do
    this = MrProxy.what_should_i_do('10x+24=124')
    this.well_do_it!.answer.should == '$x=10.0$'
  end
  it "should solve quadratic equations" do
    this = MrProxy.what_should_i_do('10x^2=1000')
    this.well_do_it!.answer.should == '$x=[-10.0,10.0]$'
  end
  it "should factor polynomials" do
    this = MrProxy.what_should_i_do('factor 6x^2+17x-45')
    this.well_do_it!.answer.should == '(3x-5)(2x+9)'
  end
  it "should politely request feedback, if confused" do
    lambda {MrProxy.what_should_i_do('').well_do_it!}.should raise_error
  end
end