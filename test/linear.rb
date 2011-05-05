require 't2-solver'
require 'rspec'
include T2Solver

describe "Solver: Linear" do
  it "should solve this" do
    Solver.new('50/(x+1)=50/100').solve!.should=='99.0'
  end
  it "should solve this" do
    Solver.new('2+1+4=x').solve!.should=='7.0'
  end
  it "should solve this" do
    Solver.new('100/2+56.4=2+(x*4)').solve!.should=='26.1'
  end
  it "should solve this" do
    Solver.new('50/(x+1)=100').solve!.should=='-0.5'
  end
  it "should solve this" do
    Solver.new('x/(2+1)=2*(1+1)').solve!.should=='12.0'
  end
  it "should solve this" do
    Solver.new('2x-x-1=14').solve!.should=='15.0'
  end
  it "should solve this" do
    Solver.new('2(x-1)=-x+4').solve!.should=='2.0'
  end
  it "should solve this" do
    Solver.new('2(x-1)=x+4').solve!.should=='6.0'
  end
  it "should solve this" do
    Solver.new('2x+x=100x').solve!.should=='0.0'
  end
end