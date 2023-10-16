defmodule Membrane.Template.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @github_url "https://github.com/jellyfish-dev/elixir_server_sdk"
  @homepage_url "https://membrane.stream"

  def project do
    [
      app: :jellyfish_server_sdk,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),

      # hex
      description: "Jellyfish Server SDK",
      package: package(),

      # docs
      name: "Jellyfish Server SDK",
      source_url: @github_url,
      homepage_url: @homepage_url,
      docs: docs(),

      # test coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp elixirc_paths(env) when env in [:test, :integration_test], do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:tesla, "~> 1.5"},
      {:mint, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:websockex, "~> 0.4.3"},
      {:elixir_uuid, "~> 1.2"},
      {:castore, "~> 1.0"},

      # protobuf deps
      {:protobuf, "~> 0.12.0"},

      # Docs, credo, test coverage, dialyzer
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, ">= 0.0.0", only: [:test, :integration_test], runtime: false},

      # Test deps
      {:plug_cowboy, "~> 2.5", only: [:test, :integration_test]},
      {:phoenix_pubsub, "~> 2.1", only: [:test, :integration_test]}
    ]
  end

  defp dialyzer() do
    opts = [
      flags: [:error_handling]
    ]

    if System.get_env("CI") == "true" do
      # Store PLTs in cacheable directory for CI
      [plt_local_path: "priv/plts", plt_core_path: "priv/plts"] ++ opts
    else
      opts
    end
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => @homepage_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [
        Jellyfish,
        Jellyfish.Exception,
        Jellyfish.Notification
      ],
      groups_for_modules: [
        Events: ~r/^Jellyfish\.((\bNotification\.[a-zA-Z]*$)|(\bMetricsReport))/
      ]
    ]
  end

  def aliases do
    [
      test: &test_or_docker/1
    ]
  end

  defp test_or_docker(_) do
    if System.find_executable("docker") do
      IO.puts("Running tests using Docker...")
      docker_compose_prefix = ["docker", "compose", "-f", "docker-compose-integration.yaml"]
      # {output, _exit_status} = System.cmd("docker", docker_compose_prefix ++ ["pull"])
      # stream_command(docker_compose_prefix ++ ["pull"])
      stream_command(docker_compose_prefix ++ ["run", "test"])
    else
      IO.puts("Running tests locally...")
      Mix.Task.run("test")
    end
  end

  defp stream_command(cmd) do
    port =
      Port.open({:spawn, Enum.join(cmd, " ")}, [
        {:line, 1024},
        :use_stdio,
        :stderr_to_stdout,
        :exit_status
      ])

    receive_and_print(port)
  end

  defp receive_and_print(port) do
    receive do
      {^port, {:data, {:eol, line}}} ->
        IO.puts(line)
        receive_and_print(port)

      {^port, {:data, data}} ->
        IO.puts(data)
        receive_and_print(port)

      {^port, {:exit_status, exit_status}} ->
        IO.puts("Docker command exited with status code: #{exit_status}")
    end
  end
end
