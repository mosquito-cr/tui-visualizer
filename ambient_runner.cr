require "mosquito"

Mosquito.configure do |settings|
  settings.redis_url = (ENV["REDIS_URL"]? || "redis://localhost:6379")
end

class ThreeSecondJob < Mosquito::QueuedJob
  def perform
    log "It only takes me three seconds to do this"
    sleep 3
  end
end

class EveryThreeSecondsJob < Mosquito::PeriodicJob
  run_every 3.seconds

  def perform
    log "I'm running every 3 seconds"
    sleep 3
  end
end

spawn {
  loop do
    ThreeSecondJob.new().enqueue
    sleep 10
  end
}

Mosquito::Runner.start
