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

    def current_task : Task?
      task_id = config["current_work"]?
      return unless task_id && ! task_id.blank?
      Task.new task_id
    end

    def last_heartbeat : Time?
      unix_ms = config["heartbeat_at"]?
      return unless unix_ms && ! unix_ms.blank?
      Time.unix(unix_ms.to_i)
    end
  end
end
