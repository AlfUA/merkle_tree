defmodule MerkleTree.Tree do
  @moduledoc """
  Merkle Tree implementation.
  Root calculation, a tree building, Merkle proof
  Get some context here: https://medium.com/@carterfeldman/a-hackers-guide-to-layer-2-merkle-trees-from-scratch-f682fc31bced
  """
  alias MerkleTree.Hash

  @max_power_of_2 50
  @powers_of_2 Enum.map(1..@max_power_of_2, fn x -> trunc(:math.pow(2, x)) end)
  @reversed_powers_of_2 Enum.map(@max_power_of_2..1, fn x -> trunc(:math.pow(2, x)) end)
  @cores_number_pow_2 [2, 4, 8, 16, 32, 64, 128, 256]
  @other_cores_number [6, 12, 14, 18, 20, 22, 24, 28, 30, 36, 40, 44, 48, 52]

  @doc """
  Computes the Merkle root for provided hashes
  """
  @spec root(hashes :: [String.t()]) :: String.t()
  def root(hashes) do
    root(hashes, [])
  end

  @doc """
  Computes the Merkle root for provided hashes in parallel if possible
  """
  @spec parallel_root(hashes :: [String.t()]) :: String.t() | :invalid_data
  def parallel_root([]), do: :invalid_data
  def parallel_root([root]), do: root

  def parallel_root(hashes) do
    {hashes, hashes_count} = maybe_duplicate_last_element(hashes, length(hashes))

    case concurrency_type_with_cores(System.schedulers_online(), hashes_count) do
      {:mono, _} ->
        root(hashes)

      {:by_row, max_concurrency} ->
        hashes
        |> Enum.chunk_every(chunk_size(hashes_count, max_concurrency))
        |> Task.async_stream(&hash_pairs(&1), max_concurrency: max_concurrency)
        |> Enum.flat_map(fn {:ok, hash} -> hash end)
        |> parallel_root()

      {:by_tree, max_concurrency} ->
        hashes
        |> Enum.chunk_every(chunk_size(hashes_count, max_concurrency))
        |> Task.async_stream(&root(&1), max_concurrency: max_concurrency)
        |> Enum.map(fn {:ok, hash} -> hash end)
        |> parallel_root()
    end
  end

  @doc """
  Calculates the number of cores to be used depending on the number of cores available and the number of blocks that need to be processed.
  If the number of elements is a power of 2, we'll build multiple subtrees in parallel and calculate a root value for them.
  If we can split the list of hashes into multiple sublists with an even number of elements, we'll calculate them in parallel.
  Otherwise (when the number of elements in the sublist is odd), we'll calculate the root value within the single process.
  This function was made public only for testing purposes.
  """
  @spec concurrency_type_with_cores(cores_available :: pos_integer(), blocks_count :: integer()) ::
          {:mono | :by_tree | :by_row, pos_integer()}

  def concurrency_type_with_cores(cores_available, blocks_count)
      when cores_available >= blocks_count,
      do: {:mono, 1}

  # case concurrency_type_with_cores(8, 64)
  def concurrency_type_with_cores(cores_available, blocks_count)
      when cores_available in @cores_number_pow_2 and blocks_count in @powers_of_2,
      do: {:by_tree, cores_available}

  # case concurrency_type_with_cores(6, 64)
  def concurrency_type_with_cores(cores_available, blocks_count)
      when cores_available in @other_cores_number and blocks_count in @powers_of_2 do
    {:by_tree, Enum.find(@reversed_powers_of_2, fn x -> x < cores_available end)}
  end

  # case concurrency_type_with_cores(8, 36)
  def concurrency_type_with_cores(cores_available, blocks_count)
      when cores_available in @cores_number_pow_2 do
    if rem(blocks_count, cores_available * 2) == 0 do
      {:by_row, cores_available}
    else
      concurrency_type_with_cores(div(cores_available, 2), blocks_count)
    end
  end

  # case concurrency_type_with_cores(6, 60)
  def concurrency_type_with_cores(cores_available, blocks_count)
      when rem(cores_available, 2) == 0 do
    if rem(blocks_count, cores_available) == 0 do
      {:by_row, cores_available}
    else
      @reversed_powers_of_2
      |> Enum.find(fn x -> x < cores_available end)
      |> concurrency_type_with_cores(blocks_count)
    end
  end

  def concurrency_type_with_cores(_cores_available, _blocks_count), do: {:mono, 1}

  defp chunk_size(hashes_count, 1), do: hashes_count

  defp chunk_size(hashes_count, max_concurrency) do
    blocks_per_core = div(hashes_count, max_concurrency)

    if blocks_per_core == 1 do
      max_concurrency
    else
      blocks_per_core
    end
  end

  defp maybe_duplicate_last_element(hashes, hashes_count) when rem(hashes_count, 2) == 0,
    do: {hashes, hashes_count}

  defp maybe_duplicate_last_element(hashes, hashes_count) do
    reversed_list = Enum.reverse(hashes)
    {Enum.reverse([hd(reversed_list) | reversed_list]), hashes_count + 1}
  end

  defp root([], [level_acc]), do: level_acc
  defp root([root], []), do: root
  defp root([], level_acc), do: root(Enum.reverse(level_acc), [])

  defp root([odd_hash], level_acc),
    do: root([], [Hash.compute_pair(odd_hash, odd_hash) | level_acc])

  defp root([left_hash | [right_hash | other_hashes]], level_acc),
    do: root(other_hashes, [Hash.compute_pair(left_hash, right_hash) | level_acc])

  defp hash_pairs(hashes), do: hash_pairs(hashes, [])

  defp hash_pairs([], result), do: Enum.reverse(result)

  defp hash_pairs([left_hash | [right_hash | other_hashes]], acc),
    do: hash_pairs(other_hashes, [Hash.compute_pair(left_hash, right_hash) | acc])
end
