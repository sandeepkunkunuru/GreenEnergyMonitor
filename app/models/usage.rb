class Usage < ActiveRecord::Base
	self.per_page = 10
	belongs_to :User
end