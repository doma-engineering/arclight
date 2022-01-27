defmodule Arclight.MixProject do
  use Mix.Project

  def project do
    [
      app: :arclight,
      version: "0.2.1-pre",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: "Minimalist Phoenix replacement for distributed (not server-centric) web.",
      package: package(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  def aliases do
    [
      test: "test --no-start"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.0"},
      {:dyn_hacks, "~> 0.1.0"},
      {:uptight, "~> 0.1.0-pre"},
      {:do_auth, "~> 0.5.0-pre"},
      {:doma_recaptcha, "~> 3.1.1-doma"},
      {:enacl, "~> 1.2"}
    ]
  end

  defp package do
    [
      licenses: ["WTFPL"],
      links: %{
        "GitHub" => "https://github.com/doma-engineering/arclight",
        "Support" => "https://social.doma.dev/@jonn",
        "Matrix" => "https://matrix.to/#/#uptight:matrix.org"
      },
      maintainers: ["doma.dev"]
    ]
  end
end
