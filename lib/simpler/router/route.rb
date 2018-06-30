module Simpler
  class Router
    class Route

      attr_reader :controller, :action, :path

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        if additional_params?
          route_pattern = build_route_pattern
        else
          route_pattern = @path
        end
        method == @method && path.match(route_pattern)
      end

      def additional_params?
        @path.include?(':')
      end

      private

      def build_route_pattern
        @path.split('/').map do |route_part|
          route_part.include?(':') ? /([a-z]|\d)+/ : route_part
        end.join('/')
      end
    end
  end
end
