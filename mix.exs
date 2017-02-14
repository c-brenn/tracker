defmodule Tracker.Mixfile do
  use Mix.Project

  def project do
    [app: :tracker,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp vial_sha do
    "5fbe46725864a5ff442e2cfebe2005579ec9f0d5"
  end

  defp deps do
    [
      {:vial, git: "https://github.com/c-brenn/vial.git", ref: vial_sha()}
    ]
  end
end
