defmodule Jellyfish.Component do
  @moduledoc """
  Defines `t:Jellyfish.Component.t/0`.

  Component is a server-side entity that can publish, subscribe to and process tracks.
  For more information refer to [Jellyfish documentation](https://jellyfish-dev.github.io/jellyfish-docs/introduction/basic_concepts).
  """

  alias Jellyfish.Component.{HLS, RTSP}
  alias Jellyfish.Exception.StructureError

  @enforce_keys [
    :id,
    :type
  ]
  defstruct @enforce_keys

  @typedoc """
  Id of the component, unique within the room.
  """
  @type id :: String.t()

  @typedoc """
  Type of the component.
  """
  @type type :: HLS | RTSP

  @typedoc """
  Component-specific options.
  """
  @type options :: HLS.t() | RTSP.t()

  @typedoc """
  Stores information about the component.
  """
  @type t :: %__MODULE__{
          id: id(),
          type: type()
        }

  @doc false
  @spec from_json(map()) :: t()
  def from_json(response) do
    case response do
      %{
        "id" => id,
        "type" => type_str
      } ->
        %__MODULE__{
          id: id,
          type: type_from_string(type_str)
        }

      _other ->
        raise StructureError
    end
  end

  @doc false
  @spec type_from_string(String.t()) :: type()
  def type_from_string("hls"), do: HLS
  def type_from_string("rtsp"), do: RTSP
  def type_from_string(_type), do: raise("Invalid component type string")

  @doc false
  @spec string_from_options(struct()) :: String.t()
  def string_from_options(%HLS{}), do: "hls"
  def string_from_options(%RTSP{}), do: "rtsp"
  def string_from_options(_struct), do: raise("Invalid component options struct")
end
