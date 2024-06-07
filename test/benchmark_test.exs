defmodule MerkleTreeTest.BenchmarkTest do
  use ExUnit.Case

  @tag :benchmark
  @tag timeout: :infinity
  test "benchmark parallel processing vs single core" do
    output =
      Benchee.run(
        %{
          "single core" => fn input -> MerkleTree.root(input) end,
          "multi core" => fn input -> MerkleTree.parallel_root(input) end
        },
        inputs: %{
          "10 blocks" => generate_data(10),
          "100 blocks" => generate_data(100),
          "1024 blocks" => generate_data(1024),
          "8192 blocks" => generate_data(8192),
          "10_000 blocks" => generate_data(10_000),
          "16_384 blocks" => generate_data(16_384),
          "100_000 blocks" => generate_data(100_000),
          "131_072 blocks" => generate_data(131_072),
          "500_000 blocks" => generate_data(500_000),
          "524_288 blocks" => generate_data(524_288),
          "1_000_000 blocks" => generate_data(1_000_000),
          "1_048_576 blocks" => generate_data(1_048_576)
        }
      )

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= 50_000_000
  end

  defp generate_data(count) do
    for _n <- 1..count do
      :sha256 |> :crypto.hash(to_string(:rand.uniform())) |> Base.encode16(case: :lower)
    end
  end
end
