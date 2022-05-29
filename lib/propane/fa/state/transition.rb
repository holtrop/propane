class Propane
  class FA
    class State

      class Transition

        attr_reader :code_point_range
        attr_reader :destination

        def initialize(code_point_range, destination)
          @code_point_range = code_point_range
          @destination = destination
        end

        def nil?
          @code_point_range.nil?
        end

      end

    end
  end
end
