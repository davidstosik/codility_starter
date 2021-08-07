# Note: I am using a Codility starter template,
# more info at https://github.com/davidstosik/codility_starter

def solution(*args)
  Solution.new(*args).run
end

# Add parameter names to Struct.new(...)
Solution = Struct.new(:array) do
  def run
    # Return solution here.
  end
end

# The solution ends here, the code below is for testing.

begin

  require "minitest"
  require "minitest/benchmark"
  require "minitest/mock"

  module TestHelpers
  end

  class TestSolution < Minitest::Test
    include TestHelpers

    def test_examples
      assert_equal 0, solution([])
    end

    def test_edge_cases
      assert_equal 0, solution([])
    end
  end

  class BenchSolution < Minitest::Benchmark
    include TestHelpers

    def setup
      @candidates = generate_candidates 
    end

    # A list of sizes that will be passed to assert_performance_* methods.
    def self.bench_range
      [1, 10, 100, 1_000, 10_000]
    end

    def bench_solution
      #assert_performance_constant do |size|
      #assert_performance_linear do |size|
      #assert_performance_exponential do |size|
      #assert_performance_logarithmic do |size|
      #assert_performance_power do |size|
      assert_performance_linear do |size|
        solution(@candidates[size])
      end
    end

    private

    def generate_candidates
      self.class.bench_range.map do |size|
        Array.new(size)
      end
    end
  end

  # Run tests (only if the RUN_TESTS environment variable is set).
  Minitest.autorun if ENV["RUN_TESTS"]

rescue LoadError
  # Do nothing (minitest may not be available on Codility).
end
