# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require 'torigoya_kit'

def make_ticket
  # source
  source = TorigoyaKit::SourceData.new("prog.c", <<EOS
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

int main() {
    puts("hello!");
    if ( raise(9) != 0 ) {
        printf("errno=%d : %s\\n", errno, strerror( errno ));
    }
    puts("unreachable!");

    return 0;
}
EOS
)

  # set of source
  sources = [source]

  # build instruction
  compile_s = TorigoyaKit::ExecutionSetting.new(
    ["/usr/bin/gcc", "-c", "prog.c", "-o", "prog.o"],
    [],
    10,
    512 * 1024 * 1024
  )
  link_s = TorigoyaKit::ExecutionSetting.new(
    ["/usr/bin/gcc", "prog.o", "-o", "prog.out"],
    ["PATH=/usr/bin:/bin"],
    10,
    512 * 1024 * 1024
  )
  bi = TorigoyaKit::BuildInstruction.new(compile_s, link_s)

  # input
  input = TorigoyaKit::Input.new(
    nil,
    TorigoyaKit::ExecutionSetting.new(
      ["./prog.out"],
      [],
      10,
      512 * 1024 * 1024
    )
  )

  # inputs
  inputs = [input]

  # run instruction
  ri = TorigoyaKit::RunInstruction.new(inputs)

  # ticket!
  ticket = TorigoyaKit::Ticket.new("", sources, bi, ri)

  return ticket
end
