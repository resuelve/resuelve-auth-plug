defmodule ResuelveAuth.Helpers.TokenData do
  @moduledoc """
  Estructura para datos genericos del token
  """

  defstruct [:role, :session, :timestamp, :meta]
end
