defmodule Jellyfish.Peer do
  @moduledoc """
  Defines `t:Jellyfish.Peer.t/0`.

  Peer is an entity that connects to the server to publish, subscribe to or publish and subscribe
  to tracks published by components and other peers.
  For more information refer to [Jellyfish documentation](https://jellyfish-dev.github.io/jellyfish-docs/introduction/basic_concepts).
  """

  alias Jellyfish.Exception.StructureError
  alias Jellyfish.Peer.WebRTC

  @enforce_keys [
    :id,
    :type,
    :status
  ]
  defstruct @enforce_keys

  @typedoc """
  Id of the peer, unique across within the room.
  """
  @type id :: String.t()

  @typedoc """
  Type of the peer.
  """
  @type type :: WebRTC

  @typedoc """
  Status of the peer.
  """
  @type status :: :disconnected | :connected

  @valid_status_strings ["disconnected", "connected"]

  @typedoc """
  Peer-specific options.
  """
  @type options :: WebRTC.t()

  @typedoc """
  Stores information about the peer.
  """
  @type t :: %__MODULE__{
          id: id(),
          type: type(),
          status: status()
        }

  @doc false
  @spec from_json(map()) :: t()
  def from_json(response) do
    case response do
      %{
        "id" => id,
        "type" => type_str,
        "status" => status_str
      } ->
        %__MODULE__{
          id: id,
          type: type_from_string(type_str),
          status: status_from_string(status_str)
        }

      _other ->
        raise StructureError
    end
  end

  @doc false
  @spec type_from_string(String.t()) :: type()
  def type_from_string("webrtc"), do: WebRTC
  def type_from_string(_type), do: raise("Invalid peer type string")

  @doc false
  @spec string_from_options(struct()) :: String.t()
  def string_from_options(%WebRTC{}), do: "webrtc"
  def string_from_options(_struct), do: raise("Invalid peer options struct")

  @doc false
  @spec status_from_string(String.t()) :: status()
  def status_from_string(status) when status in @valid_status_strings,
    do: String.to_atom(status)

  def status_from_string(_status), do: raise("Invalid peer status string")
end
