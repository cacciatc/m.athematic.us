require File.dirname(__FILE__) + '/../lib/mr-proxy'
require 'rspec'

describe "Solver: Linear" do
  it "should solve 50/(x+1)=50/100" do
    this = MrProxy.what_should_i_do('50/(x+1)=50/100')
    this.well_do_it!.answer.should == '$x=99.0$'
  end
  it "should solve 2+1+4=x" do
    this = MrProxy.what_should_i_do('2+1+4=x')
    this.well_do_it!.answer.should == '$x=7.0$'
  end
  it "should solve 100/2+56.4=2+(x*4)" do
    this = MrProxy.what_should_i_do('100/2+56.4=2+(x*4)')
    this.well_do_it!.answer.should == '$x=26.1$'
  end
  it "should solve 50/(x+1)=100" do
    this = MrProxy.what_should_i_do('50/(x+1)=100')
    this.well_do_it!.answer.should == '$x=-0.5$'
  end
  it "should solve x/(2+1)=2*(1+1)" do
    this = MrProxy.what_should_i_do('x/(2+1)=2*(1+1)')
    this.well_do_it!.answer.should == '$x=12.0$'
  end
  it "should solve 2x-x-1=14" do
    this = MrProxy.what_should_i_do('2x-x-1=14')
    this.well_do_it!.answer.should == '$x=15.0$'
  end
  it "should solve 2(x-1)=-x+4" do
    this = MrProxy.what_should_i_do('2(x-1)=-x+4')
    this.well_do_it!.answer.should == '$x=2.0$'
  end
  it "should solve 2(x-1)=x+4" do
    this = MrProxy.what_should_i_do('2(x-1)=x+4')
    this.well_do_it!.answer.should == '$x=6.0$'
  end
  it "should solve 2x+x=100x" do
    this = MrProxy.what_should_i_do('2x+x=100x')
    this.well_do_it!.answer.should == '$x=0.0$'
  end
  it "should solve -12+x=100 (issue 23)" do
    this = MrProxy.what_should_i_do('-12+x=100')
    this.well_do_it!.answer.should == '$x=112.0$'
  end
  it "should solve -x=100 (issue 23)" do
    this = MrProxy.what_should_i_do('-x=100')
    this.well_do_it!.answer.should == '$x=-100.0$'
  end
  it "should solve -(x+5)=100 (issue 23)" do
    this = MrProxy.what_should_i_do('-(x+5)=100')
    this.well_do_it!.answer.should == '$x=-105.0$'
  end
end