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
      TorigoyaKit::Ticket.new("", 0, "", [], nil, 2)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], dummy_bi, 2)
    end.to raise_error(TorigoyaKit::InvalidFormatError)

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], dummy_bi, dummy_ri)
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], dummy_bi, dummy_ri).to_msgpack
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], nil, dummy_ri)
    end.to_not raise_error

    expect do
      TorigoyaKit::Ticket.new("", 0, "", [], nil, dummy_ri).to_msgpack
    end.to_not raise_error
  end

  it "construct execution setting" do
    commands = [TorigoyaKit::Command.new("A=", "B"),
                TorigoyaKit::Command.new("unit")
               ]
    expected = TorigoyaKit::ExecutionSetting.new("test command", commands, 100, 200)

    cloned_commands = [TorigoyaKit::Command.new("A=", "B"),
                    TorigoyaKit::Command.new("unit")
                   ]
    cloned_dummy = TorigoyaKit::ExecutionSetting.new("test command", cloned_commands, 100, 200)

    expect(cloned_dummy).to eq expected
  end

  it "setting" do
    cloned_es = TorigoyaKit::ExecutionSetting.new("", [], 0, 0)
    expect(cloned_es).to eq dummy_es
  end

  it "build inst" do
    cloned_es = TorigoyaKit::ExecutionSetting.new("", [], 0, 0)
    cloned_bi = TorigoyaKit::BuildInstruction.new(cloned_es, cloned_es)

    expect(cloned_bi).to eq dummy_bi
  end

  it "run inst" do
    cloned_ri = TorigoyaKit::RunInstruction.new([])
    expect(cloned_ri).to eq dummy_ri
  end

  it "setting conversion list" do
    commands = [TorigoyaKit::Command.new("A=", "B"),
                TorigoyaKit::Command.new("unit")
               ]
    expected = TorigoyaKit::ExecutionSetting.new("test command", commands, 100, 200)

    expect(TorigoyaKit::ExecutionSetting.new("test command", [["A=", "B"], ["unit"]], 100, 200)).to eq expected
  end

  it "setting conversion list" do
    commands = [TorigoyaKit::Command.new("A=", "B"),
                TorigoyaKit::Command.new("unit")
               ]
    expected = TorigoyaKit::ExecutionSetting.new("test command", commands, 100, 200)

    expect(TorigoyaKit::ExecutionSetting.new("test command", [{"A=" => "B"}, {"unit"=>nil}], 100, 200)).to eq expected
  end

  it "source default" do
    expected = TorigoyaKit::SourceData.new("*default*", "hoge")
    expect(TorigoyaKit::SourceData.new(nil, "hoge")).to eq expected
  end
end
