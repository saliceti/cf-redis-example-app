require "sinatra"
require "json"
require "redis"

require "cloud_foundry_environment"
require "benchmark"

class ExampleApp < Sinatra::Application
  before do
    content_type "text/plain"
  end

  get "/:key" do
    key = params[:key]

    value = redis_client.get(key)
    halt 404 if value.nil?
    value
  end

  get "/benchmark/:key" do
    key = params[:key]

    time_spent = Benchmark.measure {
      benchmark_length.times {
        redis_client.get(key)
      }
    }
    time_spent.to_s
  end

  post "/:key/:value" do
    key = params[:key]
    value = params[:value]

    redis_client.set(key, value)
    status 201
  end

  post "/benchmark/:key/:value" do
    key = params[:key]
    value = params[:value]

    time_spent = Benchmark.measure {
      benchmark_length.times {
        redis_client.set(key, value)
      }
    }

    time_spent.to_s
  end

  def tell_user_how_to_bind
    bind_instructions = %{
      You must bind a Redis service instance to this application.

      You can run the following commands to create an instance and bind to it:

        $ cf create-service redis default redis-instance
        $ cf bind-service app-name redis-instance
    }
    halt 500, bind_instructions
  end

  private

  def cloud_foundry_environment
    @cloud_foundry_environment ||= CloudFoundryEnvironment.new
  end

  def redis_client
    @redis_client ||= Redis.new(:url => cloud_foundry_environment.redis_uri)
  end

  def benchmark_length
    @benchmark_length ||= cloud_foundry_environment.benchmark_length
  end

end
