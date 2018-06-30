require_relative 'view/plain_renderer'
require_relative 'view/html_renderer'

module Simpler
  class View
    def initialize(env)
      @env = env
    end

    def render(binding)
      renderer = select_renderer
      renderer.new(@env).render(binding)
    end

    private

    def select_renderer
      if plain
        class_name = 'Plain'
      elsif template
        class_name = 'Html'
      end
      Object.const_get("#{class_name}Renderer")
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def plain
      @env['simpler.plain']
    end
  end
end
