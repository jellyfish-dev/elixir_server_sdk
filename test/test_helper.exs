# IO.inspect(__ENV__.file)
# IO.inspect(Path.wildcard("./*"))
Divo.Suite.start()
IO.inspect(System.cmd("docker", ["ps"], stderr_to_stdout: true))
ExUnit.start(capture_log: true)
