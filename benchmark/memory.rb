# frozen_string_literal: true

require_relative "./base_bench"

class Memory < BaseBench
  def run
    setup_data

    without_gc do
      run_with_memory_report("AR eager loading w/ 100% usage: ") do
        ::User.all.includes(posts: :comments).map do |user|
          user.posts.to_a.each do |post|
            post.comments.to_a.each {|c| c.id}
          end
        end
      end
    end

    without_gc do
      run_with_memory_report("AR eager loading w/ 0% usage: ") do
        ::User.all.includes(posts: :comments).map do |user|
          user.id
        end
      end
    end

    without_gc do
      run_with_memory_report("AR lazy preloading w/o auto_preload w/ 100% usage: ") do
        ArLazyPreload.config.auto_preload = false

        ::User.all.lazy_preload(posts: :comments).map do |user|
          user.posts.to_a.each do |post|
            post.comments.to_a.each {|c| c.id}
          end
        end
      end
    end

    without_gc do
      run_with_memory_report("AR lazy preloading w/o auto_preload w/ 0% usage: ") do
        ArLazyPreload.config.auto_preload = false

        ::User.all.lazy_preload(posts: :comments).map do |user|
          user.id
        end
      end
    end

    without_gc do
      run_with_memory_report("AR lazy preloading w/ auto_preload w/ 100% usage: ") do
        ArLazyPreload.config.auto_preload = true

        ::User.all.map do |user|
          user.posts.to_a.each do |post|
            post.comments.to_a.each {|c| c.id}
          end
        end
      end
    end

    without_gc do
      run_with_memory_report("AR lazy preloading w/ auto_preload w/ 0% usage: ") do
        ArLazyPreload.config.auto_preload = true

        ::User.all.map do |user|
          user.id
        end
      end
    end
  end

  private

  def run_with_memory_report(section_name)
    print "\n"
    print "#{ "-" * section_name.length}\n"
    print "#{section_name.to_s.ljust(50)}\n"
    print "#{ "-" * section_name.length}\n"
    print "\n"

    print(
      MemoryProfiler.report do
        yield
      end.pretty_print,
    )
  end
end

Memory.new.run
