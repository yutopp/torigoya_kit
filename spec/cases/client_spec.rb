# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :communicate do
  c = TorigoyaClient::Client.new("localhost", 12321)

  it "Array should be " do
    c.write_request(make_ticket)
    c.recieveing()
  end
end
