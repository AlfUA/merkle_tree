defmodule MerkleTree do
  @moduledoc """
  An entry point to the application.
  Module contains user facing functions and some stuff for demo purposes.
  """
  alias MerkleTree.Tree

  @doc """
  Computes the Merkle root for provided hashes
  """
  @spec root(hashes :: [String.t()]) :: String.t()
  def root(hashes), do: Tree.root(hashes)

  @doc """
  Computes the Merkle root for provided hashes in parallel if possible
  """
  @spec parallel_root(hashes :: [String.t()]) :: String.t()
  def parallel_root(hashes), do: Tree.parallel_root(hashes)

  @doc """
  Builds Merkle tree for the provided hashes
  """
  @spec build(hashes :: [String.t()]) :: [map()]
  def build(_hashes), do: "not implemented yet"

  @doc """
  Builds Merkle tree path to prove the block is a part of a tree
  """

  @spec proof(node :: map(), index :: non_neg_integer()) :: [map()]
  def proof(_level, _index), do: "not implemented yet"

  @doc """
  Reads test data from provided file
  """
  @spec read_input!(String.t()) :: [String.t()]
  def read_input!(path \\ "priv/input.txt") do
    path
    |> File.read!()
    |> String.split("\n")
  end
end
