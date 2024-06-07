# MerkleTree

- Run `cd merkle_tree` to enter app directory
- Run `mix deps.get` to fetch dependencies
- Run `mix compile` to compile
- Run `iex -S mix` to start shell
- Run `MerkleTree.read_input! |> MerkleTree.parallel_root()` to calculate the Merkle root for the provided data
- Run `mix test test/benchmark_test.exs` to see the benchmark result (one core vs multiple cores)
- Run `mix test` to run all the tests

## Implementation notes
- According to the task we get a list of hashes, so there's no extra hashing of incoming data.
- Computations uses multiple threads when it's possible (when number of provided blocks is a power of 2)
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `merkle_tree` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:merkle_tree, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/merkle_tree>.

