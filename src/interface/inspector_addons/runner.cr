module Mosquito::Inspector
  class Runner
    def last_active : String
      if timestamp = last_heartbeat
        seconds = (Time.utc - timestamp).total_seconds.to_i

        if seconds < 21
          colorize_by_last_heartbeat seconds, "online"
        else
          colorize_by_last_heartbeat seconds, "seen #{seconds}s ago"
        end

      else
        colorize_by_last_heartbeat 301, "expired"
      end
    end

    def colorize_by_last_heartbeat(seconds : Int32, word : String) : String
      if seconds < 30
        word.colorize(:green)
      elsif seconds < 200
        word.colorize(:yellow)
      else
        word.colorize(:red)
      end.to_s
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

