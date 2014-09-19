# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :session do
  port = 23432

  it "session proc exec_ticket" do
    s = TorigoyaKit::Session.new("localhost", port)
    # p s.exec_ticket(make_ticket())
  end

  it "session proc update_proc_table" do
    s = TorigoyaKit::Session.new("localhost", port)
    expect(s.reload_proc_table()).to eq nil
  end
end
