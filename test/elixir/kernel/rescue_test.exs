Code.require_file "../../test_helper", __FILE__

defmodule Kernel::RescueTest do
  use ExUnit::Case

  def test_rescue_with_underscore_no_exception do
    true = try do
      RescueUndefinedModule.go
    rescue: _
      true
    end
  end

  def test_rescue_with_higher_precedence_than_catch do
    true = try do
      RescueUndefinedModule.go
    catch: _, _
      false
    rescue: _
      true
    end
  end

  def test_rescue_runtime_error do
    true = try do
      raise "an exception"
    rescue: RuntimeError
      true
    catch: :error, _
      false
    end

    false = try do
      raise "an exception"
    rescue: AnotherError
      true
    catch: :error, _
      false
    end
  end

  def test_rescue_named_runtime_error do
    "an exception" = try do
      raise "an exception"
    rescue: x in [RuntimeError]
      x.message
    catch: :error, _
      false
    end
  end

  def test_rescue_named_with_underscore do
    "an exception" = try do
      raise "an exception"
    rescue: x in _
      x.message
    end
  end

  def test_rescue_defined_variable do
    expected = RuntimeError

    true = try do
      raise "an exception"
    rescue: ^expected
      true
    catch: :error, _
      false
    end
  end

  def test_rescue_named_defined_variable do
    expected = RuntimeError

    "an exception" = try do
      raise "an exception"
    rescue: x in [^expected, AnotherError]
      x.message
    catch: :error, _
      false
    end
  end

  def test_wrap_custom_erlang_error do
    "erlang error :sample" = try do
      error(:sample)
    rescue: x in [RuntimeError, ErlangError]
      x.message
    end
  end

  def test_undefined_function_error do
    "undefined function ::DoNotExist.for_sure/0" = try do
      DoNotExist.for_sure()
    rescue: x in [UndefinedFunctionError]
      x.message
    end
  end

  def test_undefined_function_error_from_expected_variable do
    expected = UndefinedFunctionError
    "undefined function ::DoNotExist.for_sure/0" = try do
      DoNotExist.for_sure()
    rescue: x in [^expected]
      x.message
    end
  end

  def test_undefined_function_error_as_erlang_error do
    "undefined function ::DoNotExist.for_sure/0" = try do
      DoNotExist.for_sure()
    rescue: x in [ErlangError]
      x.message
    end
  end
end