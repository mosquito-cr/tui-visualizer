module Mosquito
  class Backend
    {% for name in ["waiting", "scheduled", "pending", "dead"] %}
      abstract def dump_{{name.id}}_q : Array(String)
    {% end %}

    module ClassMethods
      abstract def list_runners : Array(String)
    end
  end
end
