require 'geocoder'

Geocoder.configure(:units => :km)

module Location
  def self.km_between(coord, coord2)
    Geocoder::Calculations.distance_between(
      [coord[:latitude], coord[:longitude]],
      [coord2[:latitude], coord2[:longitude]]
    )
  end

  def self.nearby_users(locations, id, center, radius)
    locations.select do |user_location|
      km_between(center, user_location) < radius && user_location[:id] != id
    end
  end
end

