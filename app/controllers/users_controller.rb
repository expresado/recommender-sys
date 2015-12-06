class UsersController < ApplicationController
    def self.populate
    	file = File.read("GOOD")
    	doc = JSON.parse(file)
    	mailList = []
    	doc.each do |n|
    		email = n["user"].concat "@test.com"
    		email.downcase!
    		password = email

    		unless mailList.include? email
    			begin
	    			mailList << email
	    			tmp = User.new(
	    				"email"=>email,
	    				"password"=>password,
	    				"user_data"=>n
	    				)
	    			tmp.save!
	    			tmp=""
	    		rescue
	    			binding.pry
	    		end
    		end

    	end
    end

    def list
        @users = User.all
    end
end