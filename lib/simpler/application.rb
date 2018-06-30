require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'
require_relative 'params_parser'

module Simpler
  class Application

    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      @env = env
      route = @router.route_for(@env)
      if route
        controller = route.controller.new(@env)
        update_controller_params(controller, route) if route.additional_params?
        action = route.action
        make_response(controller, action)
      else
        error_response
      end
    end

    private

    def update_controller_params(controller, route)
      additional_params = ParamsParser.call(route, @env['REQUEST_PATH'])
      controller.update_params!(additional_params)
    end

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

    def error_response
      [404, headers, body]
    end

    def headers
      { 'Content-Type' => 'text/plain' }
    end

    def body
      ['']
    end

  end
end
