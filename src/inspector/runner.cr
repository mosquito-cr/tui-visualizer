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

    def last_active : String
      unix_ms = config["heartbeat_at"]?
      return "heartbeat expired" unless unix_ms
      timestamp = Time.unix(unix_ms.to_i)

      seconds = (Time.utc - timestamp).total_seconds.to_i
      "seen #{seconds}s ago"
    end

    def status : String
      if task = current_task
        "task: #{task.type}"
      else
        "not working"
      end
    end
  end
end
