class ParamsParser
  attr_reader :additional_params

  def self.call(route, path)
    @route_pattern = route.path
    @additional_params = build_additional_params(path)
  end

  private

  def self.build_additional_params(path)
    route_parts = @route_pattern.split('/')
    path_parts = path.split('/')
    param_names = route_parts - path_parts
    param_values = path_parts - route_parts
    params_values = param_names.zip(param_values).flatten
    Hash[*params_values]
  end
end
