defmodule Membrane.RTP.MPEGAudio.DepayloaderTest do
  use ExUnit.Case
  alias Membrane.Buffer
  alias Membrane.RTP.MPEGAudio.Depayloader

  describe "Depayloader when handling process" do
    setup do
      [state: %{}]
    end

    test "drops incoming payload that is not valid", %{state: state} do
      # too short
      for payload <- [<<>>, <<0::16>>, <<0::24>>] do
        assert Depayloader.handle_buffer(:input, %Buffer{payload: payload}, nil, state) ==
                 {[], state}
      end

      # non-zero MBZ field
      invalid_buffer = %Buffer{payload: <<1::16, 0::16, 1, 2, 3>>}
      assert Depayloader.handle_buffer(:input, invalid_buffer, nil, state) == {[], state}
    end

    test "with valid packed strips mbz and offset", %{state: state} do
      valid_buffer = %Buffer{payload: <<0::16, 128::16, 256::8, 0::256>>}

      assert Depayloader.handle_buffer(:input, valid_buffer, nil, state) ==
               {[buffer: {:output, %Buffer{payload: <<256::8, 0::256>>}}], state}
    end
  end
end
