# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require 'torigoya_kit'

def make_ticket
  # source
  source = TorigoyaKit::SourceData.new("prog.cpp", <<EOS
#include <csignal>
#include <iostream>

int main() {
    std::cout << "hello!" << std::endl;
    std::raise(8);
    std::cout << "unreachable!" << std::endl;
}
EOS
)

  # set of source
  sources = [source]

  # build instruction
  bi = TorigoyaKit::BuildInstruction.new(TorigoyaKit::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024),
                                         TorigoyaKit::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024)
                                        )
  # input
  input = TorigoyaKit::Input.new(nil,
                                 TorigoyaKit::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024)
                                 )

  # inputs
  inputs = [input]

  # run instruction
  ri = TorigoyaKit::RunInstruction.new(inputs)

  # ticket!
  ticket = TorigoyaKit::Ticket.new("aaa", 0, "test", sources, bi, ri)

  return ticket
end
