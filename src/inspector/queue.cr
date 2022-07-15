module Mosquito::Inspector
  class Queue
    include Comparable(self)

    getter name : String

    private property backend : Mosquito::Backend

    def initialize(@name)
      @backend = Mosquito.backend.named name
    end

    {% for name in ["waiting", "scheduled", "pending", "dead"] %}
      def {{name.id}}_tasks : Array(Task)
        backend.dump_{{name.id}}_q
          .map { |task_id| Task.new task_id }
      end
    {% end %}

    def <=>(other)
      name <=> other.name
    end
  end
end
