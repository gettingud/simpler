require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)
      write_response

      @response.finish
    end

    def update_params!(new_params)
      params.merge!(new_params)
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def status(code)
      @response.status = code
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def headers
      @response
    end

    def params
      @request.params
    end

    def render(options)
      if options.is_a? String
        template = options
        @request.env['simpler.template'] = template
        update_response_html(template)
      elsif options.is_a? Hash
        map_render_options(options)
      end
    end

    def map_render_options(options)
      case options.keys.first
      when :plain
        @request.env['simpler.plain'] = options.values.first
        set_content_type('text/plain')
      when :html
        template = options.values.first
        @request.env['simpler.template'] = template
        update_response_html(template)
      end
    end

    def update_response_html(template)
      set_content_type('text/html')
      set_template_path(template)
    end

    def set_template_path(template_path)
      @response['X-Template'] = template_path
    end

    def set_content_type(type)
      @response['Content-Type'] = type
    end
  end
end
