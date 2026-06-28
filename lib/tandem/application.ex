defmodule Tandem.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TandemWeb.Telemetry,
      Tandem.Repo,
      {DNSCluster, query: Application.get_env(:tandem, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tandem.PubSub},
      # Start a worker by calling: Tandem.Worker.start_link(arg)
      # {Tandem.Worker, arg},
      # Start to serve requests, typically the last entry
      TandemWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tandem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TandemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
