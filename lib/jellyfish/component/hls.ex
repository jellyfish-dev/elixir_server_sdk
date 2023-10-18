defmodule Jellyfish.Component.HLS do
  @moduledoc """
  Options for the HLS component.

  For the description of these options refer to [Jellyfish
  documentation](https://jellyfish-dev.github.io/jellyfish-docs/getting_started/components/hls).
  """

  @behaviour Jellyfish.Component.Deserializer

  @enforce_keys []
  defstruct @enforce_keys ++
              [
                low_latency: false,
                persistent: false,
                target_window_duration: nil
              ]

  @type t :: %__MODULE__{
          low_latency: boolean(),
          persistent: boolean(),
          target_window_duration: pos_integer() | nil
        }

  @impl true
  def metadata_from_json(%{
        "playable" => playable,
        "lowLatency" => low_latency,
        "persistent" => persistent,
        "targetWindowDuration" => target_window_duration
      }) do
    %{
      playable: playable,
      low_latency: low_latency,
      persistent: persistent,
      target_window_duration: target_window_duration
    }
  end
end
