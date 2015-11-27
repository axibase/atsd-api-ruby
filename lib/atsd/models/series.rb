require 'atsd/models/base_model'

module ATSD
  # Time Series model
  class Series < BaseModel
  end

  class Sample < BaseModel

    def set_time(time)
      self["t"] = time
    end

    def get_time()
      self.send("t")
    end

    def get_date()
      Time.at(self.send("t")/1000)
    end

    def set_value(value)
      self["v"] = value
    end

    def get_value()
      self.send("v")
    end

  end

  class Version < BaseModel

    def set_source(source)
      self["source"] = source
    end

    def get_source()
      self.send("source")
    end

    def set_status(status)
      self["status"] = status
    end

    def get_status()
      self.send("status")
    end
  end
end

