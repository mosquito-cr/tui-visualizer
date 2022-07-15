require "./inspector/*"

module Mosquito::Inspector
  def self.list_queues : Array(Queue)
    Mosquito.backend.list_queues
      .map { |name| Queue.new name }
  end

  def self.list_runners : Array(Runner)
    Mosquito.backend.list_runners
      .map { |name| Runner.new name }
  end
end
