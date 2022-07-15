require "uuid"

module Mosquito
  class Runner

    # How long should runner metadata stay around in the backend before expiry?
    #
    # This value _needs_ to be some multiple of how long a job takes to run.
    # When values are less than the time it takes to run a job, monitoring will
    # be chaotic and unreliable because the runner will appear to be dead or
    # defunct during long running jobs.
    #
    # The value is in seconds.
    HEARTBEAT_EXPIRATION = 300

    def run
      previous_def
      beat_heart
    end

    # This does not work if tasks take longer than the heartbeat expiration
    # interval.
    def beat_heart
      run_at_most every: 20.seconds, label: :heartbeat do
        Log.info { "Beating Heart" }

        # update the timestamp
        metadata["heartbeat_at"] = Time.utc.to_unix.to_s

        metadata.delete HEARTBEAT_EXPIRATION
      end
    end

    def metadata
      @metadata ||= Metadata.new metadata_key
    end

    def metadata_key
      Mosquito::Backend.build_key "runners", UUID.random.to_s
    end

    # todo this method contains too much complexity, when this is backported to
    # mosquito core it should be refactored
    private def run_next_task(q : Queue)
      task = q.dequeue
      return unless task

      Log.info { "#{"Running".colorize.magenta} task #{task} from #{q.name}" }

      metadata["current_work"] = task.id.to_s

      bench = Time.measure do
        task.run
      end.total_seconds

      if bench > 0.1
        time = "#{(bench).*(100).trunc./(100)}s".colorize.red
      elsif bench > 0.001
        time = "#{(bench * 1_000).trunc}ms".colorize.yellow
      elsif bench > 0.000_001
        time = "#{(bench * 100_000).trunc}µs".colorize.green
      elsif bench > 0.000_000_001
        time = "#{(bench * 1_000_000_000).trunc}ns".colorize.green
      else
        time = "no discernible time at all".colorize.green
      end

      if task.succeeded?
        Log.info { "#{"Success:".colorize.green} task #{task} finished and took #{time}" }
        q.forget task
        task.delete in: successful_job_ttl

      else
        message = "#{"Failure:".colorize.red} task #{task} failed, taking #{time}"

        if task.rescheduleable?
          interval = task.reschedule_interval
          next_execution = Time.utc + interval
          Log.warn { "#{message} and #{"will run again".colorize.cyan} in #{interval} (at #{next_execution})" }
          q.reschedule task, next_execution
        else
          Log.warn { "#{message} and #{"cannot be rescheduled".colorize.yellow}" }
          q.banish task
          task.delete in: failed_job_ttl
        end
      end

      metadata["current_work"] = ""

      # todo can we emit a warning message if the job took longer than the heartbeat expiration?
    end

  end
end
