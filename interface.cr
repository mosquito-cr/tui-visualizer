require "mosquito"
require "keimeno"

require "./src/monkeys/*"
require "./src/inspector"
require "./src/interface"

Mosquito.configure do |settings|
  settings.redis_url = (ENV["REDIS_URL"]? || "redis://localhost:6379")
end

MosquitoInterface.new.run
