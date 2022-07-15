module Mosquito::Inspector
  class Task
    getter id : String
    getter status : String

    def initialize(@id : String, @status : String)
    end

    def config_key
      Mosquito.backend.build_key Mosquito::Task::CONFIG_KEY_PREFIX, id
    end

    def type : String
      Mosquito.backend.retrieve(config_key)["type"]? || "unknown"
    end
  end
end
