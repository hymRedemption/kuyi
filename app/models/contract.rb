class Contract < ApplicationRecord
  has_many :renting_phases

  def self.generate_contract(options)
    return self.new
  end

end
