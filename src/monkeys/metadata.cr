module Mosquito
  class Metadata
    def delete(time : Int32 = 10)
      Mosquito.backend.delete root_key, time
    end
  end
end
