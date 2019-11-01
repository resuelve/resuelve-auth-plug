defmodule ResuelveAuth.Utils.Calendar do
  @moduledoc """
  Módulo que encapsula las funciones relacionadas a fecha,
  tiempo y calendario
  """

  @time_units :millisecond

  @doc """
  Identifica si la fecha enviada como Unix time es pasada.
  En caso de mandar un valor que no sea entero, regresa `true` por defecto.

  ## Examples

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

  """
  @spec is_past?(integer()) :: boolean()
  def is_past?(unix_time) when is_integer(unix_time) do
    IO.puts("is_past? .... #{unix_time}")

    datetime = Timex.from_unix(unix_time, @time_units)
    IO.puts("is_past? -> #{datetime}")
    Timex.before?(datetime, Timex.now())
  end

  def is_past?(_input), do: true

  @doc """
  Agrega el número de horas enviado a la fecha proporcionada.

  ## Examples

     iex> {:ok, datetime} = DateTime.from_unix(0)
     iex> ResuelveAuth.Utils.Calendar.add(datetime, 2, :hour)
     #DateTime<1970-01-01 02:00:00Z>

     iex> timestamp = 4128685709000
     iex> ResuelveAuth.Utils.Calendar.add(timestamp, 2, :hour)
     #DateTime<2100-10-31 19:08:29.000Z>

  """
  def add(%DateTime{} = datetime, hours, :hour) do
    Timex.shift(datetime, hours: hours)
  end

  def add(unix_time, hours, :hour) when is_integer(unix_time) do
    IO.puts("unix_time.add #{unix_time}")

    unix_time
    |> Timex.from_unix(@time_units)
    |> add(hours, :hour)
  end

  def add(_non_time, _hours, :hour), do: {:error, :invalid_time}

  def debug(input) do
    IO.puts("Out=> #{inspect(input)}")
    input
  end
end
