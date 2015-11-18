require 'atsd/models/base_model'

module ATSD
  class Entity < BaseModel
    def set_name(name)
      self["name"] = name
    end

    def get_name()
      self.send("name")
    end

    def set_enabled(enabled)
      self["enabled"] = enabled
    end

    def get_enabled()
      self.send("enabled")
    end

    def set_last_insert_time(last_insert_time)
      self["last_insert_time"] = last_insert_time
    end

    def get_last_insert_time()
      self.send("last_insert_time")
    end

    def set_last_insert_date(last_insert_date)
      self["last_insert_date"] = last_insert_date
    end

    def get_last_insert_date()
      self.send("last_insert_date")
    end

    def set_tags(tags)
      self["tags"] = tags
    end

    def get_tags()
      self.send("tags")
    end
  end
end

