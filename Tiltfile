docker_compose('docker-compose.yml')

read_file('.env')

local_resource(
  'app',
  'mix deps.get',
  serve_cmd='mix phx.server',
  deps=['config', 'mix.exs', 'mix.lock'],
  resource_deps=['postgres', 'redis']
)
