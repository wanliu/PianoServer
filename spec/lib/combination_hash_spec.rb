require 'rails_helper'
require 'combination_hash'

RSpec.describe "Combination Hash" do
	include	CombinationHash

	it "2 dim array" do 
		a = [1,2,3]
		b = [4,5,6]
		pp combination_array a , b
	end

	it "3 dim array" do 
		a = [1,2,3]
		b = [4,5,6]
		c = [7,8,9]
		pp combination_3array a , b, c
	end	

	it "n dim array" do 
		a = [1,2]
		b = [4,5]
		c = [7,8,9]
		d = [10, 11, 12]
		pp combination_arrays a, b
	end	
end
