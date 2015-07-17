# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :ticket do
  ticket = make_ticket()

  it "aaa" do
    expect(ticket).not_to be nil
  end

  it "aaa" do
    expect(ticket.to_msgpack).not_to eq nil
  end

  #
  dummy_es = TorigoyaKit::ExecutionSetting.new([], [], 0, 0)
  dummy_bi = TorigoyaKit::BuildInstruction.new(dummy_es, dummy_es)
  dummy_ri = TorigoyaKit::RunInstruction.new([])

  it "construct ticket" do
    expect do
      TorigoyaKit::Ticket.new(nil, nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", [], "", nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", [], "", "")
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new(0, [], "", "")
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", "")
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", [], dummy_bi, dummy_ri)
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", [], dummy_bi, dummy_ri).to_msgpack
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", [], nil, dummy_ri)
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", [], nil, dummy_ri).to_msgpack
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", [], dummy_bi, nil)
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", [], dummy_bi, nil).to_msgpack
    end.to_not raise_error
  end

  it "setting" do
    cloned_es = TorigoyaKit::ExecutionSetting.new([], [], 0, 0)
    expect(cloned_es).to eq dummy_es
  end

  it "build inst" do
    cloned_es = TorigoyaKit::ExecutionSetting.new([], [], 0, 0)
    cloned_bi = TorigoyaKit::BuildInstruction.new(cloned_es, cloned_es)

    expect(cloned_bi).to eq dummy_bi
  end

  it "run inst" do
    cloned_ri = TorigoyaKit::RunInstruction.new([])
    expect(cloned_ri).to eq dummy_ri
  end

  it "source default" do
    expected = TorigoyaKit::SourceData.new("*default*", "hoge")
    expect(TorigoyaKit::SourceData.new(nil, "hoge")).to eq expected
  end
end
