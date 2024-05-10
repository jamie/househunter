class Import < ApplicationRecord
  belongs_to :listing

  serialize :json, coder: JSON
end
