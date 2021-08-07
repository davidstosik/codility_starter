# Codility Starter

[Codility](https://www.codility.com/) is an automated test of programming skills.

An exercise consists in an algorithmic problem described in English, that needs to be solved by writing a `solution(...)` function which returns the expected results depending on the provided input. Sometimes, the function's performance is also evaluated.
A text editor that is able to run tests is provided in the browser, but nothing prevents the candidate to use their own text editors and tools to implement the solution which they'll just have to paste in the browser when done.

Going through multiple exercises to practice, I realized that I keep writing the same boilerplate code:

- I like to be in a class which allows me to extract concepts to private methods (helps with readability).
- Having Minitest available to write tests can be very convenient.
- When the exercise requires a performant solution, benchmarking tools come very handy.

I have extracted the boilerplate code to a reusable template in Ruby to share it here.

## Using the template

1. Install Ruby 2.2.
    Unfortunately, Codility's Ruby is a very old 2.2.0, so you'll need to make sure you run your code under the same version. (Or you'll risk to face incompatibilities.)

2. Make a copy of the template.
    This is not compulsory, but at least you'll be able to give it an explicit name, and to reuse the template if you have multiple exercises to solve.

3. Define the parameters that will be passed to your solution.
    The `Solution` class is a `Struct` which attributes are the inputs passed in. You need to change the struct to match the attributes that the solution would take. For example, if two parameters `a` and `b` are passed in, you'd write:
    ```rb
    Solution = Struct.new(:a, :b) do
    ```

4. Implement the `Solution#run` method.
    This is the method that will return the result for the solution. You can access the parameters previously defined as instance variables (eg. `a` and `b`). You have freedom to extract methods.

5. Write tests.
    The template already includes all the boilerplate code. Your first test should just be about adding all the examples provided in the exercise to the `test_examples` test case. There's also a `test_edge_cases` test case, to remind the developer that some edge cases might be worth testing. As per [Minitest](https://github.com/seattlerb/minitest), any method prefixed with `test_` in the `TestSolution` class will define a test case.

6. Benchmark.
    This step is optional, and unnecessary in some problems. (The Codility exercise usually specifies whether it wants a _performant_ solution, or just focuses on _correctness_.)
    Using [Minitest's benchmarks](https://github.com/seattlerb/minitest#benchmarks-) was convenient too. It allows us to test the performance of a solution with several methods asserting the algorithm's performance level, which should correspond to different [big O](https://en.wikipedia.org/wiki/Big_O_notation) levels of performance:
      - `assert_performance_constant`: the performance of the solution is constant, and does not depend on the problem's size (`O(1)`)
      - `assert_performance_logarithmic`: the performance solution grows _logarithmically_ with the size of the problem (`O(log n)`)
      - `assert_performance_linear`: ... _linearly_ ... (`O(n)`)
      - `assert_performance_power`: ... _in a polynomial fashion_ ... (`O(n^c)`)
      - `assert_performance_exponential`: ... _exponentially_ ... (`O(c^n)`)

    (Note that the paragraph above might be very approximate, as my theoretical knowledge around _big O_ notation and algorithm performance is a bit rusty. Suggestions to improve are welcome!)

    The `bench_range` class method returns a list of problem sizes used to benchmark the solution. You may need to remove the bigger sizes, or adjust the numbers in other ways, in case the problem is very complex and slow to solve.

    Playing around with the `assert_performance_` method that you use, you should be able, in most cases, to determine the performance of your solution. See [minitest/benchmark](https://github.com/seattlerb/minitest#benchmarks-)'s documentation for more details.

7. Run locally to see the results.
    You can now run the file locally to see if you tests pass:
    ```sh
    RUN_TESTS=1 ruby my_file.rb
    ```
    It is necessary to set the environment variable `RUN_TESTS=1`, as without it, nothing will run. (This is the trick that allows us to paste the whole file as-is in Codility.)

8. Paste your solution in Codility's editor.
    Once you are satisfied with your solution, you can paste the whole file in the editor. This is convenient as you'll be able to use quick ways to copy the whole code such as `Cmd+A Cmd+C` (select all, copy), or `cat my_file.rb | pbcopy` (on macOS).

## Concepts

Codility expects a script that defines the `solution(...)` method:

```rb
def solution(n)
  # write your code in Ruby 2.2
end
```

To accomodate different signatures required by different excercises, I used the variable number of arguments in my template.
As I like to write the logic of my script inside a class, I defined one that can be initialized with the `solution` method's parameters. An easy way to do so is to use a [`Struct`](https://ruby-doc.org/core-2.2.0/Struct.html):

```rb
def solution(*args)
  Solution.new(*args).run
end

Solution = Struct.new(:array) do
  def run
    # Return solution here.
  end
end
```

In the example above, the input is a single parameter which I named `array`.

Implementing the solution now consists in writing the body of the `run` method.
There's indeed little difference with simply writing the body of the `solution` method, but it introduces some convenience.
Consider for example the solution to the [_Parking Bill_ problem](https://app.codility.com/programmers/trainings/5/parking_bill/), below:

```rb
Solution = Struct.new(:entered, :left) do
  ENTRANCE_FEE = 2
  FIRST_HOUR_COST = 3
  NEXT_HOURS_COST = 4

  def run
    fixed_cost + variable_cost
  end

  def fixed_cost
    ENTRANCE_FEE + FIRST_HOUR_COST
  end

  def variable_cost
    number_of_hours_after_first * NEXT_HOURS_COST
  end

  def number_of_hours_after_first
    (time_in_minutes / 60.0).ceil - 1
  end

  def time_in_minutes
    hour_difference * 60 + left_minutes - entered_minutes
  end

  def hour_difference
    left_hours - entered_hours
  end

  def entered_minutes
    entered.split(":").last.to_i
  end

  def left_minutes
    left.split(":").last.to_i
  end

  def entered_hours
    entered.split(":").first.to_i
  end

  def left_hours
    left.split(":").first.to_i
  end
end
```

With many small methods, I can initialize my solution object once, and inspect the value returned by the different logical steps of my algorithm:

```rb
solution = Solution.new("10:00", "13:21")
solution.hour_difference
#=> 3
solution.variable_cost
#=> 12
solution.run
#=> 17
```
  
I'm also a strong believer in code readability, and some recruiters might too. Even though Codility is probably not the best tool to judge code readability and other code-related skills (except for algorithmic!), it is possible that some recruiters will judge your solution not only on its correctness and performance, but also on how easy it was for them to read and understand it. It might be worth making an effort if it's not a time sink (which this template helps with).

For comparison, this is how I could have written the same solution, caring only about correctness:

```rb
def solution(e, l)
  e_h, e_m = entered.split(":").map(&:to_i)
  l_h, l_m = left.split(":").map(&:to_i)

  ((((l_h - e_h) * 60 - e_m + l_m) / 60.0).ceil - 1) * 4 + 3 + 2
end
```

Of course there are many levels of readability between these two extremes, but writing the first implementation didn't really require me more time, and it had the benefit to clarify the algorithm for myself, preventing mistakes, misplaced brackets, off-by-one errors, etc.
We're entering the domain of general programming advice though, which is not the purpose of this repository. If you are looking for more, I'd recommend [The Art of Readable Code](https://www.semanticscholar.org/paper/The-Art-of-Readable-Code-Boswell-Foucher/aeb8a50fcb5474bedc0a6f18928afbfaea5d7e05?sort=is-influential) (Dustin Boswell, Trevor Foucher), it's a great read on the topic.

I guess one could also simply define methods on the top-level `main` `Object`, but I'm somehow not comfortable with it, and prefer having my method decomposition inside a well-defined class.

Now the rest of the file, below the definition of the `Solution` class, is all about testing.

The file loads minitest (with a failsafe, as it does not seem available on Codility), and in addition will also run `minitest/autorun`, only if the right environment variable is set. This is what allows me to get the tests to run locally while being harmless when pasted as-is in Codility's editor.

Then two test classes are defined: `TestSolution` for standard tests and `BenchSolution` for benchmarks.

## Before getting started

Before getting started with the test, which is timed, you will want to make sure you go through this checklist for peace of mind:

- Install the right version of Ruby (2.2.x)
    You may face troubles, such as the ones I did when I tried to install Ruby 2.2.9 on macOS Big Sur a few days ago. ([This helped.](https://stackoverflow.com/a/65525762))
    You definitely don't want to be wasting your precious test time on such problem.
- Get your tools ready: is your system up-to-date? Your laptop charged? Do you have your favorite editor set up properly?
- Get familiar with the template if you plan to use it.
- Get familiar with Codility. It is worth going through a few trial runs to get used with Codility's UI and concepts. There are plenty of challenges, lessons and trainings which you can do to get an idea.


Good luck with the test!
