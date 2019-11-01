defmodule ResuelveAuth.Utils.Calendar do
  @moduledoc """
  Módulo que encapsula las funciones relacionadas a fecha,
  tiempo y calendario
  """

  @spec is_past?(integer()) :: boolean()
  def is_past?(unix_time) when is_integer(unix_time) do
    IO.puts("unis_t #{inspect(unix_time)}")

    unix_time
    |> DateTime.from_unix()
    |> get(:limit)
    |> Timex.before?(Timex.now())
  end

  def is_past?(_input), do: true

  def get({:ok, date}, :limit) do
    Timex.shift(date, hours: 2)
  end

  def get({:error, error}, :limit) do
    {:error, error}
  end
end
