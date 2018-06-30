require 'logger'

class HttpLogger
  def initialize(app)
    @app = app
    log_path = Simpler.root.join('log/app.log')
    @logger = Logger.new(log_path)
  end

  def call(env)
    @request = Rack::Request.new(env)
    @status, @headers, @body = @app.call(env)
    update_log
    [@status, @headers, @body]
  end

  private

  def update_log
    log_request
    log_params
    log_handler
    log_response
    @logger.close
  end

  def log_request
    request_uri = @request.env['REQUEST_URI']
    request = "#{@request.request_method} #{request_uri}\n"
    @logger.info('Request') { request }
  end

  def log_params
    @logger.info('Params') { @request.params.to_s + "\n" }
  end

  def log_handler
    controller = @request.env['simpler.controller'].class.name
    handler = "#{controller}##{@request.env['simpler.action']}\n"
    @logger.info('Handler') { handler }
  end

  def log_response
    content_type = @headers['Content-Type']
    template = @headers['X-Template']
    response = "#{@status} [#{content_type}] #{template}\n"
    @logger.info('Response') { response }
  end
end
