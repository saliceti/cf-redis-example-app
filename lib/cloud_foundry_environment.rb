class CloudFoundryEnvironment
  NoRedisBoundError = Class.new(StandardError)

  def initialize(services = ENV.to_h.fetch("VCAP_SERVICES"))
    @services = JSON.parse(services)
  end

  def redis_uri
    if services.has_key?("user-provided")
      services.fetch("user-provided").first.fetch("credentials").fetch("uri")
    else
      raise NoRedisBoundError
    end

    rescue KeyError => e
      puts e.message
      raise NoRedisBoundError
  end

  def benchmark_length
    ENV.to_h.fetch("BENCHMARK_LENGTH", "100").to_i
  end

  private

  attr_reader :services
end
