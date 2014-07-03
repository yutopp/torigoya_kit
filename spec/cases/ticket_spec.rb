# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :ticket do
  ticket = make_ticket()

  it "aaa" do
    expect(ticket).not_to eq nil
  end

  it "aaa" do
    expect(ticket.to_msgpack).not_to eq nil
  end
end
