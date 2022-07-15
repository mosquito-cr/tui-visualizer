module Mosquito::Inspector
  class Runner
    include Comparable(self)

    getter name : String

    def initialize(name)
      @name = name
    end

    def <=>(other)
      name <=> other.name
    end

    def config
      key = Mosquito.backend.build_key "runners", name
      config = Mosquito.backend.retrieve key
    end

    def last_active : String
      unix_ms = config["heartbeat_at"]?
      return "heartbeat expired" unless unix_ms
      timestamp = Time.unix(unix_ms.to_i)

      seconds = (Time.utc - timestamp).total_seconds.to_i
      "seen #{seconds}s ago"
    end
  end
end
