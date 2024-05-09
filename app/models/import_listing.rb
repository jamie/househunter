class ImportListing < ApplicationRecord
  serialize :json, coder: JSON
end
