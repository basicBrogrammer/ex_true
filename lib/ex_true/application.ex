defmodule ExTrue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExTrue.Repo,
      # Start the Telemetry supervisor
      ExTrueWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExTrue.PubSub},
      # Start the Endpoint (http/https)
      ExTrueWeb.Endpoint
      # Start a worker by calling: ExTrue.Worker.start_link(arg)
      # {ExTrue.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExTrue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExTrueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
