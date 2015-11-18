require 'atsd/models/base_model'

module ATSD
  class Metric < BaseModel

    def set_name(name)
      self["name"] = name
    end

    def get_name()
      self.send("name")
    end

    def set_label(label)
      self["label"] = label
    end

    def get_label()
      self.send("label")
    end

    def set_enabled(enabled)
      self["enabled"] = enabled
    end

    def get_enabled()
      self.send("enabled")
    end

    def set_data_type(data_type)
      self["data_type"] = data_type
    end

    def get_data_type()
      self.send("data_type")
    end

    def set_time_precision(time_precision)
      self["time_precision"] = time_precision
    end

    def get_time_precision()
      self.send("time_precision")
    end

    def set_persistent(persistent)
      self["persistent"] = persistent
    end

    def get_persistent()
      self.send("persistent")
    end

    def set_counter(counter)
      self["counter"] = counter
    end

    def get_counter()
      self.send("counter")
    end

    def set_filter(filter)
      self["filter"] = filter
    end

    def get_filter()
      self.send("filter")
    end

    def set_min_value(min_value)
      self["min_value"] = min_value
    end

    def get_min_value()
      self.send("min_value")
    end

    def set_max_value(max_value)
      self["max_value"] = max_value
    end

    def get_max_value()
      self.send("max_value")
    end

    def set_invalid_action(invalid_action)
      self["invalid_action"] = invalid_action
    end

    def get_invalid_action()
      self.send("invalid_action")
    end

    def set_description(description)
      self["description"] = description
    end

    def get_description()
      self.send("description")
    end

    def set_retention_interval(retention_interval)
      self["retention_interval"] = retention_interval
    end

    def get_retention_interval()
      self.send("retention_interval")
    end

    def set_last_insert_time(last_insert_time)
      self["last_insert_time"] = last_insert_time
    end

    def get_last_insert_time()
      self.send("last_insert_time")
    end

    def get_last_insert_date()
      Time.at(self.send("last_insert_time")/1000)
    end

    # def set_last_insert_date(last_insert_date)
    #   self["last_insert_date"] = last_insert_date
    # end

    def set_versioned(versioned)
      self["versioned"] = versioned
    end

    def get_versioned()
      self.send("versioned")
    end

    def set_tags(tags)
      self["tags"] = tags
    end

    def get_tags()
      self.send("tags")
    end

  end

  module DataType
    SHORT = 'SHORT'
    INTEGER = 'INTEGER'
    FLOAT = 'FLOAT'
    LONG = 'LONG'
    DOUBLE = 'DOUBLE'
  end

  module TimePrecision
    SECONDS = 'SECONDS'
    MILLISECONDS = 'MILLISECONDS'
  end

  module InvalidAction
    NONE = 'NONE'
    DISCARD = 'DISCARD'
    TRANSFORM = 'TRANSFORM'
    RAISE_ERROR = 'RAISE_ERROR'
  end

  # class Enum
  #   def self.keys
  #     constants
  #   end
  #
  #   def self.values
  #     @values ||= constants.map { |const| const_get(const) }
  #   end
  # end
  # class Enum
  #   def self.keys
  #     constants
  #   end
  #
  #   def self.values
  #     @values ||= constants.map { |const| const_get(const) }
  #   end
  # end
  #
  # class Data_Type < Enum
  #   SHORT='SHORT'
  #   INTEGER='INTEGER'
  #   FLOAT='FLOAT'
  #   LONG='LONG'
  #   DOUBLE='DOUBLE'
  # end
  #
  # class Time_Precision < Enum
  #   SECONDS='SECONDS'
  #   MILLISECONDS='MILLISECONDS'
  # end
  #
  # class Invalid_Action < Enum
  #   NONE='NONE'
  #   DISCARD='DISCARD'
  #   TRANSFORM='TRANSFORM'
  #   RAISE_ERROR='RAISE_ERROR'
  # end

end












