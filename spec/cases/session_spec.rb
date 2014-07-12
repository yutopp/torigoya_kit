# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require_relative '../spec_helper'

describe :session do
  it "session proc exec_ticket" do
    s = TorigoyaKit::Session.new("localhost", 49800)
    # p s.exec_ticket(make_ticket())
  end

  it "session proc update_proc_table" do
    #s = TorigoyaKit::Session.new("localhost", 22222)
    #s.update_packages()
    #s.exec_ticket(make_ticket())
    #s.update_proc_table()
    #p s.get_proc_table()
  end
end
