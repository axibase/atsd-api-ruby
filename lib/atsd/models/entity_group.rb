require 'atsd/models/base_model'
require 'atsd/models/entity'

module ATSD
  class EntityGroup < BaseModel
    def set_name(name)
      self["name"] = name
    end

    def get_name()
      self.send("name")
    end

    def set_expression(expression)
      self["expression"] = expression
    end

    def get_expression()
      self.send("expression")
    end

    def set_tags(tags)
      self["tags"] = tags
    end

    def get_tags()
      self.send("tags")
    end
  end
end

