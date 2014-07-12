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
  dummy_es = TorigoyaKit::ExecutionSetting.new("", [], 0, 0)
  dummy_bi = TorigoyaKit::BuildInstruction.new(dummy_es, dummy_es)
  dummy_ri = TorigoyaKit::RunInstruction.new([])

  it "construct ticket" do
    expect do
      TorigoyaKit::Ticket.new(nil, nil, nil, nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", nil, nil, nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, nil, nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", nil, nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], nil, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], dummy_bi, nil)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], dummy_bi, dummy_ri)
    end.to_not raise_error
  end

  it "construct execution setting" do
    commands = [TorigoyaKit::Command.new("A=", "B"),
                TorigoyaKit::Command.new("unit")
               ]
    expected = TorigoyaKit::ExecutionSetting.new("test command", commands, 100, 200)

    commands_dummy = [TorigoyaKit::Command.new("A=", "B"),
                      TorigoyaKit::Command.new("unit")
                     ]
    expected_dummy = TorigoyaKit::ExecutionSetting.new("test command", commands, 100, 200)

    expect(expected).to eq expected_dummy
  end

  it "setting" do
    expected_es = TorigoyaKit::ExecutionSetting.new("", [], 0, 0)
    expect(expected_es).to eq dummy_es
  end

  it "build inst" do
    expected_es = TorigoyaKit::ExecutionSetting.new("", [], 0, 0)
    expected_bi = TorigoyaKit::BuildInstruction.new(expected_es, expected_es)

    expect(expected_bi).to eq dummy_bi
  end

  it "run inst" do
    expected_ri = TorigoyaKit::RunInstruction.new([])
    expect(expected_ri).to eq dummy_ri
  end
end
