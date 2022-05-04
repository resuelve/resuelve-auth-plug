defmodule ResuelveAuth.Utils.Calendar do
  @moduledoc """
  Encapsulates the functions related to the date.
  If using a time library is required,
  it should be added here the desired functionality.
  In the project you should only find calls to
  the `Calendar` module to facilitate code maintenance.
  """

  @time_units :millisecond
  require Logger

  @doc """
  Converts the given Unix time to DateTime.

  ```elixir

  iex> alias ResuelveAuth.Utils.Calendar
  iex> {:ok, %DateTime{} = date} = Calendar.from_unix(1572617244)
  iex> DateTime.to_unix(date)
  1572617

  iex> alias ResuelveAuth.Utils.Calendar
  iex> Calendar.from_unix(1724.0)
  {:error, :invalid_unix_time}

  iex> alias ResuelveAuth.Utils.Calendar
  iex> Calendar.from_unix("algo")
  {:error, :invalid_unix_time}

  ```

  """
  @spec from_unix(integer()) :: {:ok, DateTime.t()} | {:error, any()}
  def from_unix(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp, @time_units) do
      {:ok, time} ->
        {:ok, time}

      {:error, reason} ->
        Logger.error(fn -> "Datetime from unix fail: #{inspect(reason)}" end)
        {:error, :invalid_unix_time}
    end
  end

  def from_unix(_no_integer), do: {:error, :invalid_unix_time}

  @doc """
  Identifies if the date sent as Unix time is passed.
  In case of sending a value that is not an integer, it returns `true` by default.

  ## Examples

  ```elixir

     iex> alias ResuelveAuth.Utils.Calendar
     iex> unix_time = 1572617244
     iex> Calendar.is_past?(unix_time)
     true

     iex> alias ResuelveAuth.Utils.Calendar
     iex> unix_time = 4128685709000
     iex> Calendar.is_past?(unix_time)
     false

     iex> alias ResuelveAuth.Utils.Calendar
     iex> Calendar.is_past?("2100-02-29T12:30:30+00:00")
     true

  ```

  """
  @spec is_past?(integer() | tuple()) :: boolean()
  def is_past?(unix_time) when is_integer(unix_time) do
    unix_time
    |> DateTime.from_unix(@time_units)
    |> is_past?()
  end

  def is_past?({:ok, %DateTime{} = datetime}) do
    datetime
    |> DateTime.compare(DateTime.utc_now())
    |> case do
      :lt -> true
      _ -> false
    end
  end

  def is_past?(_input), do: true

  @doc """
  Returns the current date in `unix time`.

  ## Example

  ```elixir

  > ResuelveAuth.Utils.Calendar.unix_now()
  1577733231563

  ```
  """
  @spec unix_now() :: integer()
  def unix_now do
    DateTime.utc_now()
    |> DateTime.to_unix(@time_units)
  end

  @doc """
  Returns the difference between two dates in unix format.

  ## Example

  ```elixir

  iex> {ayer, ahora} = {1577646287000, 1577733231563}
  iex> {:ok, first} = DateTime.from_unix(ayer, :millisecond)
  iex> {:ok, second} = DateTime.from_unix(ahora, :millisecond)
  iex> ResuelveAuth.Utils.Calendar.diff(first, second)
  -24

  iex> {ayer, ahora} = {1577646287000, 1577733231563}
  iex> {:ok, first} = DateTime.from_unix(ayer, :millisecond)
  iex> {:ok, second} = DateTime.from_unix(ahora, :millisecond)
  iex> ResuelveAuth.Utils.Calendar.diff(second, first)
  24

  ```
  """
  @spec diff(map(), map()) :: integer()
  def diff(first_time, second_time) do
    seconds = DateTime.diff(first_time, second_time)
    hours = seconds / (60 * 60)
    Kernel.trunc(hours)
  end
end
