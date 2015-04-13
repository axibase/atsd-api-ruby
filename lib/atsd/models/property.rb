require 'atsd/models/base_model'

module ATSD
  # Property model
  #
  # @note Please use `property[:key]` instead of `property.key` to access
  #   `key` attribute due to implementation details (`#key` is a Hash method).
  class Property < BaseModel
  end
end

