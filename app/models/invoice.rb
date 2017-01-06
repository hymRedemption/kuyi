class Invoice < ApplicationRecord
  has_many :line_items
end
