docker_compose('docker-compose.yml')
dc_resource('pgadmin', labels=["admin"])
dc_resource('postgres', labels=["database"])
dc_resource('redis', labels=["database"])

read_file('.env')
local_resource(
  'app',
  'mix deps.get',
  serve_cmd='mix phx.server',
  deps=['config', 'mix.exs', 'mix.lock'],
  resource_deps=['postgres', 'redis'],
  labels=["backend"]
)
