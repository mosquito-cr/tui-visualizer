require "uuid"

module Mosquito
  class Runner
    def run
      previous_def
      beat_heart
    end

    def beat_heart
      run_at_most every: 20.seconds, label: :heartbeat do
        Log.info { "Beating Heart" }

        # update the timestamp
        metadata["heartbeat_at"] = Time.utc.to_unix.to_s

        # ask redis to clean up evidence of this runner after 5 minutes of inactivity
        metadata.delete 300
      end
    end

    def metadata
      @metadata ||= Metadata.new metadata_key
    end

    def metadata_key
      Mosquito::Backend.build_key "runners", UUID.random.to_s
    end
  end
end
