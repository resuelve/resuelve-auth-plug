defmodule ResuelveAuth.Utils.Calendar do
  @moduledoc """
  Encapsula las funciones relacionadas con la fecha.
  Si se requiere usar alguna biblioteca de tiempo, aquí debe agregarse
  la funcionalidad deseada y en el proyecto solo se deben encontrar
  llamadas al módulo de Calendar para facilitar el mantenimiento del código.
  """

  @time_units :millisecond
  require Logger

  @spec from_unix(integer()) :: {:ok, %DateTime{}} | {:error, any()}
  def from_unix(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp, @time_units) do
      {:ok, time} ->
        {:ok, time}

      {:error, reason} ->
        Logger.error("datetime from unix fail: #{inspect(reason)}")
        {:error, :invalid_unix_time}
    end
  end

  def from_unix(_no_integer), do: {:error, :invalid_unix_time}

  @doc """
  Identifica si la fecha enviada como Unix time es pasada.
  En caso de mandar un valor que no sea entero, regresa `true` por defecto.

  ## Ejemplos

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
  @spec is_past?(integer()) :: boolean()
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
  Regresa la fecha actual en `unix time`.

  ## Ejemplo:

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
  Regresa la diferencia en horas de dos fechas enviadas como parámetros en formato
  unix.

  ## Ejemplo:

  ```elixir

  iex> {ayer, ahora} = {1577646287000, 1577733231563}
  iex> {:ok, first} = DateTime.from_unix(ayer, :millisecond)
  iex> {:ok, second} = DateTime.from_unix(ahora, :millisecond)
  iex> ResuelveAuth.Utils.Calendar.diff(first, second)
  - 24

  iex> {ayer, ahora} = {1577646287000, 1577733231563}
  iex> {:ok, first} = DateTime.from_unix(ayer, :millisecond)
  iex> {:ok, second} = DateTime.from_unix(ahora, :millisecond)
  iex> ResuelveAuth.Utils.Calendar.diff(second, first)
  24

  ```
  """
  @spec diff(integer(), integer()) :: integer()
  def diff(first_time, second_time) do
    seconds = DateTime.diff(first_time, second_time)
    # to hours
    hours = seconds / (60 * 60)
    Kernel.trunc(hours)
  end
end
