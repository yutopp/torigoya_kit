# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require 'torigoya_client'

def make_ticket
  # source
  source = TorigoyaClient::SourceData.new("prog.cpp", <<EOS
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
  bi = TorigoyaClient::BuildInstruction.new(TorigoyaClient::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024),
                                            TorigoyaClient::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024)

                                        )
  # input
  input = TorigoyaClient::Input.new(nil,
                                    TorigoyaClient::ExecutionSetting.new("", [], 10, 512 * 1024 * 1024)
                                    )

  # inputs
  inputs = [input]

  # run instruction
  ri = TorigoyaClient::RunInstruction.new(inputs)

  # ticket!
  ticket = TorigoyaClient::Ticket.new("aaa", 0, "test", sources, bi, ri)

  return ticket
end
