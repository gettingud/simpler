class HtmlRenderer
  TEMPLATE_BASE_PATH = 'app/views'.freeze

  def initialize(env)
    @env = env
  end

  def render(binding)
    template = File.read(template_path)
    ERB.new(template).result(binding)
  end

  def template
    @env['simpler.template']
  end

  def template_path
    path = template || [controller.name, action].join('/')

    Simpler.root.join(TEMPLATE_BASE_PATH, "#{path}.html.erb")
  end
end
