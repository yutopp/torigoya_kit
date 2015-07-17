# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :request_protocol do
  b = TorigoyaKit::Protocol::Packet.new(
    TorigoyaKit::Protocol::MessageKindTicketRequest,    # kind
    42,             # version
    {"test": 42}    # data
  )

  it "size of @kind should be 1" do
    expect(b.kind.size).to eq 1
  end

  it "@kind should be TorigoyaKit::Protocol::MessageKindAcceptRequest" do
    expect(b.kind.bytes).to eq [0x01]
  end

  it "size of @version should be 4" do
    expect(b.version.size).to eq 4
  end

  it "@version should be 42" do
    expect(b.version.bytes).to eq [0x2a, 0x00, 0x00, 0x00]
  end

  it "size of @length should be 4" do
    expect(b.length.size).to eq 4
  end

  it "@length should be 3" do
    expect(b.length.bytes).to eq [0x07, 0x00, 0x00, 0x00]
  end

  it "size of @message should be 7" do
    expect(b.message.size).to eq 7
  end

  it "@message should be [129, 164, 116, 101, 115, 116, 42]" do
    expect(b.message.bytes).to eq [129, 164, 116, 101, 115, 116, 42]
  end
end
