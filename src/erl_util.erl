-module(erl_util).

-include_lib("eunit/include/eunit.hrl").

-export([test_with_timeout/2]).

test_with_timeout(Timeout, Test_func) ->
  {timeout, Timeout, [fun() -> Test_func() end]}.
