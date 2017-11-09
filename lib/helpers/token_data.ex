defmodule ResuelveAuth.Helpers.TokenData do
  @moduledoc """
  Estructura para datos genericos del token
  """

  defstruct [:service, :role, :session, :timestamp, :meta]
end
