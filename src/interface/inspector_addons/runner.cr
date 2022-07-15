module Mosquito::Inspector
  class Runner
    def last_active : String
      if timestamp = last_heartbeat
        seconds = (Time.utc - timestamp).total_seconds.to_i
        "seen #{seconds}s ago"
      else
        "heartbeat expired"
      end
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

