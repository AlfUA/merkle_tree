defmodule MerkleTree.TreeTest do
  use ExUnit.Case

  alias MerkleTree.{Hash, Tree}

  describe "root/1" do
    test "when even number of hashes passed" do
      hashes = generate_data(4)
      [hash1, hash2, hash3, hash4] = hashes
      hash12 = Hash.compute_pair(hash1, hash2)
      hash34 = Hash.compute_pair(hash3, hash4)
      assert Hash.compute_pair(hash12, hash34) == Tree.root(hashes)
    end

    test "when odd number of hashes passed" do
      hashes = generate_data(5)
      [hash1, hash2, hash3, hash4, hash5] = hashes
      hash12 = Hash.compute_pair(hash1, hash2)
      hash34 = Hash.compute_pair(hash3, hash4)
      hash56 = Hash.compute_pair(hash5, hash5)
      hash1234 = Hash.compute_pair(hash12, hash34)
      hash5678 = Hash.compute_pair(hash56, hash56)
      assert Hash.compute_pair(hash1234, hash5678) == Tree.root(hashes)
    end
  end

  describe "parallel_root/1" do
    test "when even number of hashes passed" do
      hashes = generate_data(4)
      [hash1, hash2, hash3, hash4] = hashes
      hash12 = Hash.compute_pair(hash1, hash2)
      hash34 = Hash.compute_pair(hash3, hash4)
      assert Hash.compute_pair(hash12, hash34) == Tree.parallel_root(hashes)
    end

    test "when odd number of hashes passed" do
      hashes = generate_data(5)
      [hash1, hash2, hash3, hash4, hash5] = hashes
      hash12 = Hash.compute_pair(hash1, hash2)
      hash34 = Hash.compute_pair(hash3, hash4)
      hash56 = Hash.compute_pair(hash5, hash5)
      hash1234 = Hash.compute_pair(hash12, hash34)
      hash5678 = Hash.compute_pair(hash56, hash56)
      assert Hash.compute_pair(hash1234, hash5678) == Tree.parallel_root(hashes)
    end
  end

  describe "compare results for root/1 and parallel_root/1" do
    test "for various number of hashes" do
      hashes_6 = generate_data(6)
      assert Tree.root(hashes_6) == Tree.parallel_root(hashes_6)

      hashes_7 = generate_data(7)
      assert Tree.root(hashes_7) == Tree.parallel_root(hashes_7)

      hashes_8 = generate_data(8)
      assert Tree.root(hashes_8) == Tree.parallel_root(hashes_8)

      hashes_9 = generate_data(9)
      assert Tree.root(hashes_9) == Tree.parallel_root(hashes_9)

      hashes_10 = generate_data(10)
      assert Tree.root(hashes_10) == Tree.parallel_root(hashes_10)

      hashes_20 = generate_data(20)
      assert Tree.root(hashes_20) == Tree.parallel_root(hashes_20)

      hashes_36 = generate_data(36)
      assert Tree.root(hashes_36) == Tree.parallel_root(hashes_36)

      hashes_50 = generate_data(50)
      assert Tree.root(hashes_50) == Tree.parallel_root(hashes_50)

      hashes_60 = generate_data(60)
      assert Tree.root(hashes_60) == Tree.parallel_root(hashes_60)

      hashes_64 = generate_data(64)
      assert Tree.root(hashes_64) == Tree.parallel_root(hashes_64)

      hashes_128 = generate_data(128)
      assert Tree.root(hashes_128) == Tree.parallel_root(hashes_128)

      hashes_1024 = generate_data(1024)
      assert Tree.root(hashes_1024) == Tree.parallel_root(hashes_1024)

      hashes_8192 = generate_data(8192)
      assert Tree.root(hashes_8192) == Tree.parallel_root(hashes_8192)

      hashes_10_000 = generate_data(10_000)
      assert Tree.root(hashes_10_000) == Tree.parallel_root(hashes_10_000)

      hashes_16_384 = generate_data(16_384)
      assert Tree.root(hashes_16_384) == Tree.parallel_root(hashes_16_384)

      hashes_32_768 = generate_data(32_768)
      assert Tree.root(hashes_32_768) == Tree.parallel_root(hashes_32_768)

      hashes_50_000 = generate_data(50_000)
      assert Tree.root(hashes_50_000) == Tree.parallel_root(hashes_50_000)
    end
  end

  describe "concurrency_type_with_cores/2 calculates number of cores" do
    test "when number of cores and number of blocks are equal" do
      assert Tree.concurrency_type_with_cores(1, 1) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 4) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 8) == {:mono, 1}
    end

    test "when number of cores and number of blocks are not equal" do
      assert Tree.concurrency_type_with_cores(4, 1) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 2) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 4) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 6) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 8) == {:by_tree, 4}
      assert Tree.concurrency_type_with_cores(4, 10) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 12) == {:by_row, 2}
      assert Tree.concurrency_type_with_cores(4, 48) == {:by_row, 4}
      assert Tree.concurrency_type_with_cores(4, 50) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(4, 52) == {:by_row, 2}
      assert Tree.concurrency_type_with_cores(4, 56) == {:by_row, 4}
      assert Tree.concurrency_type_with_cores(4, 64) == {:by_tree, 4}
      assert Tree.concurrency_type_with_cores(4, 100) == {:by_row, 2}

      assert Tree.concurrency_type_with_cores(6, 1) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 2) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 4) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 6) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 8) == {:by_tree, 4}
      assert Tree.concurrency_type_with_cores(6, 10) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 12) == {:by_row, 6}
      assert Tree.concurrency_type_with_cores(6, 16) == {:by_tree, 4}
      assert Tree.concurrency_type_with_cores(6, 30) == {:by_row, 6}
      assert Tree.concurrency_type_with_cores(6, 50) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(6, 60) == {:by_row, 6}
      assert Tree.concurrency_type_with_cores(6, 64) == {:by_tree, 4}
      assert Tree.concurrency_type_with_cores(6, 100) == {:by_row, 2}

      assert Tree.concurrency_type_with_cores(8, 1) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 2) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 4) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 6) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 8) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 10) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 12) == {:by_row, 2}
      assert Tree.concurrency_type_with_cores(8, 14) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 16) == {:by_tree, 8}
      assert Tree.concurrency_type_with_cores(8, 18) == {:mono, 1}
      assert Tree.concurrency_type_with_cores(8, 36) == {:by_row, 2}
      assert Tree.concurrency_type_with_cores(8, 64) == {:by_tree, 8}
      assert Tree.concurrency_type_with_cores(8, 16_384) == {:by_tree, 8}
      assert Tree.concurrency_type_with_cores(8, 1_000_000) == {:by_row, 8}
      assert Tree.concurrency_type_with_cores(8, 1_048_576) == {:by_tree, 8}
    end
  end

  defp generate_data(count) do
    for _n <- 1..count do
      :sha256 |> :crypto.hash(to_string(:rand.uniform())) |> Base.encode16(case: :lower)
    end
  end
end
