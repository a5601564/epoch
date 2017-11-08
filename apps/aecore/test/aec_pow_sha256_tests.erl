%%%=============================================================================
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc
%%%   Unit tests for the aec_pow_sha256 module
%%% @end
%%%=============================================================================
-module(aec_pow_sha256_tests).

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").
-include("sha256.hrl").
-include("pow.hrl").

-define(TEST_MODULE, aec_pow_sha256).

pow_test_() ->
    {setup,
     fun setup/0,
     fun teardown/1,
     begin
         [{"Generate with very high target threshold",
           fun() ->
                   {T1, Res} = timer:tc(?TEST_MODULE, generate, [<<"hello there">>, ?HIGHEST_TARGET_SCI, 1]),
                   ?debugFmt("~nReceived result ~p~nin ~p microsecs~n~n", [Res, T1]),
                   ?assertEqual({ok, {1, no_value}}, Res),

                   %% verify
                   {T2, Res2} = timer:tc(?TEST_MODULE, verify,
                                         [<<"hello there">>, 1, no_value, ?HIGHEST_TARGET_SCI]),
                   ?debugFmt("~nVerified in ~p microsecs~n~n", [T2]),
                   ?assertEqual(true, Res2)
           end},
          {"Generate with low target threshold, shall fail",
           fun() ->
                   Res = ?TEST_MODULE:generate(<<"hello there">>, 16#01010000, 1),
                   ?assertEqual({error, no_solution}, Res)
           end}
         ]
     end
    }.

setup() ->
    crypto:start().

teardown(_) ->
    crypto:stop().

-endif.
