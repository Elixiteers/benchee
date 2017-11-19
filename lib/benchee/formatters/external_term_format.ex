defmodule Benchee.Formatters.ExternalTermFormat do
  @moduledoc """
  Store the whole suite in the Erlang `ExternalTermFormat` - can be used for
  storing and loading the results of previous runs.
  """

  use Benchee.Formatter

  alias Benchee.Suite
  alias Benchee.Benchmark.Scenario
  alias Benchee.Utility.FileCreation

  @spec format(Suite.t) :: {binary, String.t}
  def format(suite = %Suite{configuration: config, scenarios: scenarios}) do
    formatter_config = config.formatter_options.external_term_format
    tagged_scenarios = tag_scenarios(scenarios, formatter_config)
    tagged_suite = %Suite{suite | scenarios: tagged_scenarios}

    {:erlang.term_to_binary(tagged_suite), formatter_config.file}
  end

  defp tag_scenarios(scenarios, %{tag: tag}) do
    Enum.map scenarios, fn(scenario) ->
      tagged_scenario(scenario, tag)
    end
  end

  defp tagged_scenario(scenario = %Scenario{tag: nil}, desired_tag) do
    %Scenario{scenario | tag: desired_tag}
  end
  defp tagged_scenario(scenario, _desired_tag) do
    scenario
  end

  @spec write({binary, String.t}) :: :ok
  def write({term_binary, filename}) do
    FileCreation.ensure_directory_exists(filename)
    return_value = File.write(filename, term_binary)

    IO.puts "Suite saved in external term format at #{filename}"

    return_value
  end
end
