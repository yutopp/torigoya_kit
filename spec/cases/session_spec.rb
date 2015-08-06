# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :session do
  port = 23456

  it "session proc exec_ticket" do
    s = TorigoyaKit::Session.new("localhost", port)
    t = s.exec_ticket(make_ticket())
    p t
    expect(t.compile.result.system_error_status).to eq 0
    expect(t.compile.result.exited).to eq true
    expect(t.compile.result.exit_status).to eq 0

    expect(t.link.result.system_error_status).to eq 0
    expect(t.link.result.exited).to eq true
    expect(t.link.result.exit_status).to eq 0

    expect(t.run[0].result.system_error_status).to eq 0
    expect(t.run[0].result.exited).to eq false
    expect(t.run[0].result.signaled).to eq true
    expect(t.run[0].result.signal).to eq 9
    #expect(t.run[0].result.exit_status).to eq 0
  end

  it "session proc update_packages" do
    s = TorigoyaKit::Session.new("localhost", port)
    expect(s.update_packages()).to eq 0
  end
end
