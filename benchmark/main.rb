# frozen_string_literal: true

require_relative "./base_bench"

class Bench < BaseBench
  def run
    setup_data

    Benchmark.bm(50) do |x|
      run_bench(x, usage_percent: 100)
      run_bench(x, usage_percent: 50)
      run_bench(x, usage_percent: 10)
      run_bench(x, usage_percent: 0)

      run_bench(x, usage_percent: 100, auto_preload: false)
      run_bench(x, usage_percent: 50, auto_preload: false)
      run_bench(x, usage_percent: 10, auto_preload: false)
      run_bench(x, usage_percent: 0, auto_preload: false)

      run_bench(x, usage_percent: 100, auto_preload: true)
      run_bench(x, usage_percent: 50, auto_preload: true)
      run_bench(x, usage_percent: 10, auto_preload: true)
      run_bench(x, usage_percent: 0, auto_preload: true)
    end
  end

  private

  def run_bench(x, usage_percent:, auto_preload: nil)
    label =
      case auto_preload
      when nil then "AR eager loading"
      when false then "AR lazy preloading w/o auto_preload"
      when true then "AR lazy preloading w/ auto_preload"
      end

    without_gc do
      ArLazyPreload.config.auto_preload = auto_preload unless auto_preload.nil?

      scope = auto_preload ? User.all : ::User.all.includes(posts: :comments)

      x.report("#{label} #{usage_percent}% usage: ") do
        scope.map do |user|
          if usage_percent.zero?
            user.id
          elsif (user.id % (100 / usage_percent)).zero?
            user.posts.each { |post| post.comments.each(&:id) }
          end
        end
      end
    end
  end
end

Bench.new.run
