defmodule MerkleTree.Hash do
  @moduledoc """
   MerkleTree.Hash module defines function to compute hash value using different algorithms
  """
  @type algorithm :: :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512
  @spec compute(data :: String.t(), algorithm :: algorithm()) :: String.t()
  def compute(data, algorithm \\ :sha256) do
    algorithm |> :crypto.hash(data) |> Base.encode16(case: :lower)
  end

  @spec compute_pair(left :: String.t(), right :: String.t(), algorithm :: algorithm()) ::
          String.t()
  def compute_pair(left, right, algorithm \\ :sha256) do
    algorithm |> :crypto.hash(left <> right) |> Base.encode16(case: :lower)
  end
end
