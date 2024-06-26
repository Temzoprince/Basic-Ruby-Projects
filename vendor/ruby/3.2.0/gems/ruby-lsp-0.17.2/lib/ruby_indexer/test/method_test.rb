# typed: true
# frozen_string_literal: true

require_relative "test_case"

module RubyIndexer
  class MethodTest < TestCase
    def test_method_with_no_parameters
      index(<<~RUBY)
        class Foo
          def bar
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
    end

    def test_conditional_method
      index(<<~RUBY)
        class Foo
          def bar
          end if condition
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
    end

    def test_singleton_method_using_self_receiver
      index(<<~RUBY)
        class Foo
          def self.bar
          end
        end
      RUBY

      assert_entry("bar", Entry::SingletonMethod, "/fake/path/foo.rb:1-2:2-5")
    end

    def test_singleton_method_using_other_receiver_is_not_indexed
      index(<<~RUBY)
        class Foo
          def String.bar
          end
        end
      RUBY

      assert_no_entry("bar")
    end

    def test_method_under_dynamic_class_or_module
      index(<<~RUBY)
        module Foo
          class self::Bar
            def bar
            end
          end
        end

        module Bar
          def bar
          end
        end
      RUBY

      assert_equal(2, @index["bar"].length)
      first_entry = T.must(@index["bar"].first)
      assert_equal("Foo::self::Bar", first_entry.owner.name)
      second_entry = T.must(@index["bar"].last)
      assert_equal("Bar", second_entry.owner.name)
    end

    def test_visibility_tracking
      index(<<~RUBY)
        private def foo
        end

        def bar; end

        protected

        def baz; end
      RUBY

      assert_entry("foo", Entry::InstanceMethod, "/fake/path/foo.rb:0-8:1-3", visibility: Entry::Visibility::PRIVATE)
      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:3-0:3-12", visibility: Entry::Visibility::PUBLIC)
      assert_entry("baz", Entry::InstanceMethod, "/fake/path/foo.rb:7-0:7-12", visibility: Entry::Visibility::PROTECTED)
    end

    def test_visibility_tracking_with_nested_class_or_modules
      index(<<~RUBY)
        class Foo
          private

          def foo; end

          class Bar
            def bar; end
          end

          def baz; end
        end
      RUBY

      assert_entry("foo", Entry::InstanceMethod, "/fake/path/foo.rb:3-2:3-14", visibility: Entry::Visibility::PRIVATE)
      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:6-4:6-16", visibility: Entry::Visibility::PUBLIC)
      assert_entry("baz", Entry::InstanceMethod, "/fake/path/foo.rb:9-2:9-14", visibility: Entry::Visibility::PRIVATE)
    end

    def test_method_with_parameters
      index(<<~RUBY)
        class Foo
          def bar(a)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(1, entry.parameters.length)
      parameter = entry.parameters.first
      assert_equal(:a, parameter.name)
      assert_instance_of(Entry::RequiredParameter, parameter)
    end

    def test_method_with_destructed_parameters
      index(<<~RUBY)
        class Foo
          def bar((a, (b, )))
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(1, entry.parameters.length)
      parameter = entry.parameters.first
      assert_equal(:"(a, (b, ))", parameter.name)
      assert_instance_of(Entry::RequiredParameter, parameter)
    end

    def test_method_with_optional_parameters
      index(<<~RUBY)
        class Foo
          def bar(a = 123)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(1, entry.parameters.length)
      parameter = entry.parameters.first
      assert_equal(:a, parameter.name)
      assert_instance_of(Entry::OptionalParameter, parameter)
    end

    def test_method_with_keyword_parameters
      index(<<~RUBY)
        class Foo
          def bar(a:, b: 123)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(2, entry.parameters.length)
      a, b = entry.parameters

      assert_equal(:a, a.name)
      assert_instance_of(Entry::KeywordParameter, a)

      assert_equal(:b, b.name)
      assert_instance_of(Entry::OptionalKeywordParameter, b)
    end

    def test_method_with_rest_and_keyword_rest_parameters
      index(<<~RUBY)
        class Foo
          def bar(*a, **b)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(2, entry.parameters.length)
      a, b = entry.parameters

      assert_equal(:a, a.name)
      assert_instance_of(Entry::RestParameter, a)

      assert_equal(:b, b.name)
      assert_instance_of(Entry::KeywordRestParameter, b)
    end

    def test_method_with_post_parameters
      index(<<~RUBY)
        class Foo
          def bar(*a, b)
          end

          def baz(**a, b)
          end

          def qux(*a, (b, c))
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(2, entry.parameters.length)
      a, b = entry.parameters

      assert_equal(:a, a.name)
      assert_instance_of(Entry::RestParameter, a)

      assert_equal(:b, b.name)
      assert_instance_of(Entry::RequiredParameter, b)

      entry = T.must(@index["baz"].first)
      assert_equal(2, entry.parameters.length)
      a, b = entry.parameters

      assert_equal(:a, a.name)
      assert_instance_of(Entry::KeywordRestParameter, a)

      assert_equal(:b, b.name)
      assert_instance_of(Entry::RequiredParameter, b)

      entry = T.must(@index["qux"].first)
      assert_equal(2, entry.parameters.length)
      _a, second = entry.parameters

      assert_equal(:"(b, c)", second.name)
      assert_instance_of(Entry::RequiredParameter, second)
    end

    def test_method_with_destructured_rest_parameters
      index(<<~RUBY)
        class Foo
          def bar((a, *b))
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(1, entry.parameters.length)
      param = entry.parameters.first

      assert_equal(:"(a, *b)", param.name)
      assert_instance_of(Entry::RequiredParameter, param)
    end

    def test_method_with_block_parameters
      index(<<~RUBY)
        class Foo
          def bar(&block)
          end

          def baz(&)
          end
        end
      RUBY

      entry = T.must(@index["bar"].first)
      param = entry.parameters.first
      assert_equal(:block, param.name)
      assert_instance_of(Entry::BlockParameter, param)

      entry = T.must(@index["baz"].first)
      assert_equal(1, entry.parameters.length)

      param = entry.parameters.first
      assert_equal(Entry::BlockParameter::DEFAULT_NAME, param.name)
      assert_instance_of(Entry::BlockParameter, param)
    end

    def test_method_with_anonymous_rest_parameters
      index(<<~RUBY)
        class Foo
          def bar(*, **)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_equal(2, entry.parameters.length)
      first, second = entry.parameters

      assert_equal(Entry::RestParameter::DEFAULT_NAME, first.name)
      assert_instance_of(Entry::RestParameter, first)

      assert_equal(Entry::KeywordRestParameter::DEFAULT_NAME, second.name)
      assert_instance_of(Entry::KeywordRestParameter, second)
    end

    def test_method_with_forbidden_keyword_splat_parameter
      index(<<~RUBY)
        class Foo
          def bar(**nil)
          end
        end
      RUBY

      assert_entry("bar", Entry::InstanceMethod, "/fake/path/foo.rb:1-2:2-5")
      entry = T.must(@index["bar"].first)
      assert_empty(entry.parameters)
    end

    def test_keeps_track_of_method_owner
      index(<<~RUBY)
        class Foo
          def bar
          end
        end
      RUBY

      entry = T.must(@index["bar"].first)
      owner_name = T.must(entry.owner).name

      assert_equal("Foo", owner_name)
    end

    def test_keeps_track_of_attributes
      index(<<~RUBY)
        class Foo
          # Hello there
          attr_reader :bar, :other
          attr_writer :baz
          attr_accessor :qux
        end
      RUBY

      assert_entry("bar", Entry::Accessor, "/fake/path/foo.rb:2-15:2-18")
      assert_equal("Hello there", @index["bar"].first.comments.join("\n"))
      assert_entry("other", Entry::Accessor, "/fake/path/foo.rb:2-21:2-26")
      assert_equal("Hello there", @index["other"].first.comments.join("\n"))
      assert_entry("baz=", Entry::Accessor, "/fake/path/foo.rb:3-15:3-18")
      assert_entry("qux", Entry::Accessor, "/fake/path/foo.rb:4-17:4-20")
      assert_entry("qux=", Entry::Accessor, "/fake/path/foo.rb:4-17:4-20")
    end

    def test_ignores_attributes_invoked_on_constant
      index(<<~RUBY)
        class Foo
        end

        Foo.attr_reader :bar
      RUBY

      assert_no_entry("bar")
    end

    def test_properly_tracks_multiple_levels_of_nesting
      index(<<~RUBY)
        module Foo
          def first; end

          module Bar
            def second; end
          end

          def third; end
        end
      RUBY

      entry = T.must(@index["first"]&.first)
      assert_equal("Foo", T.must(entry.owner).name)

      entry = T.must(@index["second"]&.first)
      assert_equal("Foo::Bar", T.must(entry.owner).name)

      entry = T.must(@index["third"]&.first)
      assert_equal("Foo", T.must(entry.owner).name)
    end
  end
end
