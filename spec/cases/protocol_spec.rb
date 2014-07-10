# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :request_protocol do
  b = TorigoyaClient::Protocol::Packet.new(TorigoyaClient::Protocol::MessageKindAcceptRequest, 12345)

  it "size of kind should be 1" do
    expect(b.kind.size).to eq 1
  end

  it "kind should be TorigoyaQueue::Protocol::MessageKindAcceptRequest" do
    expect(b.kind.bytes).to eq [0x00]
  end

  it "size of size should be 3" do
    expect(b.size.size).to eq 4
  end

  it "size should be [0x03, 0x00, 0x00, 0x00]" do
    expect(b.size.bytes).to eq [0x03, 0x00, 0x00, 0x00]
  end

  it "size of encoded_data should be 3" do
    expect(b.encoded_data.size).to eq 3
  end

  it "encoded_data should be [205, 48, 57]" do
    expect(b.encoded_data.bytes).to eq [205, 48, 57]
  end
end
