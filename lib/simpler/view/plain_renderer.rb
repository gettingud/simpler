class PlainRenderer
  def initialize(env)
    @env = env
  end

  def render(binding)
    @env['simpler.plain']
  end
end
