class SelfIccard < ActiveRecord::Base
  belongs_to :user, required: true
  validates :card_id, presence: true
  validates :card_id, uniqueness: true

  searchable do
    text :card_id
    text :user_name do
      user.name
    end
    integer :user_id
  end

  paginates_per 10
end
