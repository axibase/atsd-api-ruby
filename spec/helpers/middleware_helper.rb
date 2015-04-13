class LastEnvMiddleware < Faraday::Response::Middleware
  class << self
    attr_accessor :last_env
  end

  def call(environment)
    @app.call(environment).on_complete do |env|
      self.class.last_env = env
    end
  end
end
