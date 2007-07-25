require "examples/example_helper"

module RR
describe ScenarioDefinition, :shared => true do
  before do
    @space = Space.new
    @object = Object.new
    def @object.foobar(a, b)
      [b, a]
    end
    @double = @space.double(@object, :foobar)
    @scenario = @space.scenario(@double)
    @definition = @scenario.definition
  end
end

describe ScenarioDefinition, "#with" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.with(1).should === @definition
  end

  it "sets an ArgumentEqualityExpectation" do
    @definition.with(1)
    @definition.should be_exact_match(1)
    @definition.should_not be_exact_match(2)
  end

  it "sets return value when block passed in" do
    @definition.with(1) {:return_value}
    @object.foobar(1).should == :return_value
  end
end

describe ScenarioDefinition, "#with_any_args" do
  it_should_behave_like "RR::ScenarioDefinition"

  before do
    @definition.with_any_args {:return_value}
  end

  it "returns ScenarioDefinition" do
    @definition.with_no_args.should === @definition
  end

  it "sets an AnyArgumentExpectation" do
    @definition.should_not be_exact_match(1)
    @definition.should be_wildcard_match(1)
  end

  it "sets return value when block passed in" do
    @object.foobar(:anything).should == :return_value
  end
end

describe ScenarioDefinition, "#with_no_args" do
  it_should_behave_like "RR::ScenarioDefinition"

  before do
    @definition.with_no_args {:return_value}
  end

  it "returns ScenarioDefinition" do
    @definition.with_no_args.should === @definition
  end

  it "sets an ArgumentEqualityExpectation with no arguments" do
    @definition.argument_expectation.should == Expectations::ArgumentEqualityExpectation.new()
  end

  it "sets return value when block passed in" do
    @object.foobar().should == :return_value
  end
end

describe ScenarioDefinition, "#never" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.never.should === @definition
  end

  it "sets up a Times Called Expectation with 0" do
    @definition.with_any_args
    @definition.never
    proc {@object.foobar}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.never
    proc {@object.foobar}.should raise_error(Errors::TimesCalledError)
  end
end

describe ScenarioDefinition, "#once" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.once.should === @definition
  end

  it "sets up a Times Called Expectation with 1" do
    @definition.once.with_any_args
    @object.foobar
    proc {@object.foobar}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.once {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#twice" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.twice.should === @definition
  end

  it "sets up a Times Called Expectation with 2" do
    @definition.twice.with_any_args
    @object.foobar
    @object.foobar
    proc {@object.foobar}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.twice {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#at_least" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.with_any_args.at_least(2).should === @definition
  end

  it "sets up a Times Called Expectation with 1" do
    @definition.at_least(2)
    @definition.times_matcher.should == TimesCalledMatchers::AtLeastMatcher.new(2)
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.at_least(2) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#at_most" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.with_any_args.at_most(2).should === @definition
  end

  it "sets up a Times Called Expectation with 1" do
    @definition.at_most(2).with_any_args
    @object.foobar
    @object.foobar
    proc do
      @object.foobar
    end.should raise_error(
      Errors::TimesCalledError,
      "Called 3 times.\nExpected at most 2 times."
    )
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.at_most(2) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#times" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.times(3).should === @definition
  end

  it "sets up a Times Called Expectation with passed in times" do
    @definition.times(3).with_any_args
    @object.foobar
    @object.foobar
    @object.foobar
    proc {@object.foobar}.should raise_error(Errors::TimesCalledError)
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.times(3) {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#any_number_of_times" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.any_number_of_times.should === @definition
  end

  it "sets up a Times Called Expectation with AnyTimes matcher" do
    @definition.any_number_of_times
    @definition.times_matcher.should == TimesCalledMatchers::AnyTimesMatcher.new
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.any_number_of_times {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#ordered" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "adds itself to the ordered scenarios list" do
    @definition.ordered
    @space.ordered_scenarios.should include(@scenario)
  end

  it "does not double add itself" do
    @definition.ordered
    @definition.ordered
    @space.ordered_scenarios.should == [@scenario]
  end

  it "sets ordered? to true" do
    @definition.ordered
    @definition.should be_ordered
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.once.ordered {:return_value}
    @object.foobar.should == :return_value
  end
end

describe ScenarioDefinition, "#ordered?" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "defaults to false" do
    @definition.should_not be_ordered
  end
end

describe ScenarioDefinition, "#yields" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.yields(:baz).should === @definition
  end

  it "yields the passed in argument to the call block when there is no returns value set" do
    @definition.with_any_args.yields(:baz)
    passed_in_block_arg = nil
    @object.foobar {|arg| passed_in_block_arg = arg}.should == nil
    passed_in_block_arg.should == :baz
  end

  it "yields the passed in argument to the call block when there is a no returns value set" do
    @definition.with_any_args.yields(:baz).returns(:return_value)

    passed_in_block_arg = nil
    @object.foobar {|arg| passed_in_block_arg = arg}.should == :return_value
    passed_in_block_arg.should == :baz
  end

  it "sets return value when block passed in" do
    @definition.with_any_args.yields {:return_value}
    @object.foobar {}.should == :return_value
  end
end

describe ScenarioDefinition, "#after_call" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.after_call {}.should === @definition
  end

  it "sends return value of Scenario implementation to after_call" do
    return_value = {}
    @definition.with_any_args.returns(return_value).after_call do |value|
      value[:foo] = :bar
      value
    end

    actual_value = @object.foobar
    actual_value.should === return_value
    actual_value.should == {:foo => :bar}
  end

  it "receives the return value in the after_call callback" do
    return_value = :returns_value
    @definition.with_any_args.returns(return_value).after_call do |value|
      :after_call_value
    end

    actual_value = @object.foobar
    actual_value.should == :after_call_value
  end

  it "allows after_call to mock the return value" do
    return_value = Object.new
    @definition.with_any_args.returns(return_value).after_call do |value|
      mock(value).inner_method(1) {:baz}
      value
    end

    @object.foobar.inner_method(1).should == :baz
  end

  it "raises an error when not passed a block" do
    proc do
      @definition.after_call
    end.should raise_error(ArgumentError, "after_call expects a block")
  end
end

describe ScenarioDefinition, "#returns" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns ScenarioDefinition" do
    @definition.returns {:baz}.should === @definition
    @definition.returns(:baz).should === @definition
  end

  it "sets the value of the method when passed a block" do
    @definition.with_any_args.returns {:baz}
    @object.foobar.should == :baz
  end

  it "sets the value of the method when passed an argument" do
    @definition.returns(:baz).with_no_args
    @object.foobar.should == :baz
  end

  it "returns false when passed false" do
    @definition.returns(false).with_any_args
    @object.foobar.should == false
  end

  it "raises an error when both argument and block is passed in" do
    proc do
      @definition.returns(:baz) {:another}
    end.should raise_error(ArgumentError, "returns cannot accept both an argument and a block")
  end
end

describe ScenarioDefinition, "#implemented_by" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns the ScenarioDefinition" do
    @definition.implemented_by(proc{:baz}).should === @definition
  end

  it "sets the implementation to the passed in proc" do
    @definition.implemented_by(proc{:baz}).with_no_args
    @object.foobar.should == :baz
  end

  it "sets the implementation to the passed in method" do
    def @object.foobar(a, b)
      [b, a]
    end
    @definition.implemented_by(@object.method(:foobar))
    @object.foobar(1, 2).should == [2, 1]
  end
end

describe ScenarioDefinition, "#implemented_by_original_method" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns the ScenarioDefinition object" do
    @definition.implemented_by_original_method.should === @definition
  end

  it "sets the implementation to the original method" do
    @definition.implemented_by_original_method.with_any_args
    @object.foobar(1, 2).should == [2, 1]
  end

  it "calls method_missing when original_method does not exist" do
    class << @object
      def method_missing(method_name, *args, &block)
        "method_missing for #{method_name}(#{args.inspect})"
      end
    end
    double = @space.double(@object, :does_not_exist)
    scenario = @space.scenario(double)
    scenario.with_any_args
    scenario.implemented_by_original_method

    return_value = @object.does_not_exist(1, 2)
    return_value.should == "method_missing for does_not_exist([1, 2])"
  end
end

describe ScenarioDefinition, "#exact_match?" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns false when no expectation set" do
    @definition.should_not be_exact_match()
    @definition.should_not be_exact_match(nil)
    @definition.should_not be_exact_match(Object.new)
    @definition.should_not be_exact_match(1, 2, 3)
  end

  it "returns false when arguments are not an exact match" do
    @definition.with(1, 2, 3)
    @definition.should_not be_exact_match(1, 2)
    @definition.should_not be_exact_match(1)
    @definition.should_not be_exact_match()
    @definition.should_not be_exact_match("does not match")
  end

  it "returns true when arguments are an exact match" do
    @definition.with(1, 2, 3)
    @definition.should be_exact_match(1, 2, 3)
  end
end

describe ScenarioDefinition, "#wildcard_match?" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns false when no expectation set" do
    @definition.should_not be_wildcard_match()
    @definition.should_not be_wildcard_match(nil)
    @definition.should_not be_wildcard_match(Object.new)
    @definition.should_not be_wildcard_match(1, 2, 3)
  end

  it "returns true when arguments are an exact match" do
    @definition.with(1, 2, 3)
    @definition.should be_wildcard_match(1, 2, 3)
    @definition.should_not be_wildcard_match(1, 2)
    @definition.should_not be_wildcard_match(1)
    @definition.should_not be_wildcard_match()
    @definition.should_not be_wildcard_match("does not match")
  end

  it "returns true when with_any_args" do
    @definition.with_any_args

    @definition.should be_wildcard_match(1, 2, 3)
    @definition.should be_wildcard_match(1, 2)
    @definition.should be_wildcard_match(1)
    @definition.should be_wildcard_match()
    @definition.should be_wildcard_match("does not match")
  end
end

describe ScenarioDefinition, "#terminal?" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns true when times_called_expectation's terminal? is true" do
    @definition.once
    @definition.times_called_expectation.should be_terminal
    @definition.should be_terminal
  end

  it "returns false when times_called_expectation's terminal? is false" do
    @definition.any_number_of_times
    @definition.times_called_expectation.should_not be_terminal
    @definition.should_not be_terminal
  end

  it "returns false when there is not times_called_expectation" do
    @definition.times_called_expectation.should be_nil
    @definition.should_not be_terminal
  end
end

describe ScenarioDefinition, "#expected_arguments" do
  it_should_behave_like "RR::ScenarioDefinition"

  it "returns argument expectation's expected_arguments when there is a argument expectation" do
    @definition.with(1, 2)
    @definition.expected_arguments.should == [1, 2]
  end

  it "returns an empty array when there is no argument expectation" do
    @definition.argument_expectation.should be_nil
    @definition.expected_arguments.should == []
  end
end
end