require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    validates :password,
        length: {in: 5..10}
    has_many :contributions
    has_many :likes
    has_many :liked_contributions, through: :likes, source: :contribution, dependent: :destroy
    has_many :comments
    has_many :commented_contributions, through: :comments, source: :contribution, dependent: :destroy
end

class Contribution < ActiveRecord::Base
    belongs_to :user
    has_many :likes
    has_many :liked_users, through: :likes, source: :user, dependent: :destroy
    has_many :comments
    has_many :commented_users, through: :comments, source: :user, dependent: :destroy
end

class Like < ActiveRecord::Base
    belongs_to :user
    belongs_to :contribution
end

class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :contribution
end