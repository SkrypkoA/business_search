class Business < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :address, scope: [:state, :city]
  validates_uniqueness_of :place_id, allow_blank: true

  def full_address
    [address, city, state, zip].compact.join(', ')
  end

  def self.build_by_place(place)
    new(
      address: place.description,
      place_id: place.place_id
    )
  end
end
