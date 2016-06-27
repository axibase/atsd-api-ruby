require 'atsd/models/base_model'

module ATSD
  # Time Series model
  class Series < BaseModel
  end

  class Sample < BaseModel

    def set_date(date)
      self['d'] = date
    end

    def get_date()
      self.send('d')
    end

    def set_value(value)
      self['v'] = value
    end

    def get_value()
      self.send('v')
    end

    # Converts date as d
    # for the rest operates as a superclass method
    def []=(key,value)
      if key.to_s == 'date'
        key = :d
      end
      super(key, value)
    end

  end

  class Version < BaseModel

    def set_source(source)
      self['source'] = source
    end

    def get_source()
      self.send('source')
    end

    def set_status(status)
      self['status'] = status
    end

    def get_status()
      self.send('status')
    end
  end
end

