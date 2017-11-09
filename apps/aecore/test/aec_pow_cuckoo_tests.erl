%%%=============================================================================
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc
%%%   Unit tests for the aec_pow_cuckoo module
%%% @end
%%%=============================================================================
-module(aec_pow_cuckoo_tests).

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").
-include("pow.hrl").

-define(TEST_MODULE, aec_pow_cuckoo).

pow_test_() ->
    {setup,
     fun() ->
             meck:new(application, [unstick, passthrough]),
             meck:expect(application, get_env, 3,
                         fun(aecore, aec_pow_cuckoo, _) -> {mean16, "-t 5", 16};
                            (App, Key, Def) ->
                                 meck:passthrough([App, Key, Def])
                         end),
             application:start(erlexec)
     end,
     fun(_) ->
             application:stop(erlexec),
             meck:validate(application),
             meck:unload(application)
     end,
     [{"Generate with a winning nonce and high target threshold, verify it",
       {timeout, 60,
        fun() ->
                %% succeeds in a single step
                {T1, Res} = timer:tc(?TEST_MODULE, generate,
                                     [<<"wsffgujnjkqhduihsahswgdf">>, ?HIGHEST_TARGET_SCI, 122]),
                ?debugFmt("~nReceived result ~p~nin ~p microsecs~n~n", [Res, T1]),
                ?assertEqual(ok, element(1, Res)),

               %% verify the beast
               {ok, {Nonce, Soln}} = Res,
               {T2, Res2} = timer:tc(?TEST_MODULE, verify,
                                     [<<"wsffgujnjkqhduihsahswgdf">>, Nonce, Soln, ?HIGHEST_TARGET_SCI]),
               ?debugFmt("~nVerified in ~p microsecs~n~n", [T2]),
               ?assertEqual(true, Res2)
       end}
     },
     {"Generate with a winning nonce but low target threshold, shall fail",
      {timeout, 90,
       fun() ->
               Res = ?TEST_MODULE:generate(<<"wsffgujnjkqhduihsahswgdf">>, 16#01010000, 122),
               ?assertEqual({error, no_solution}, Res)
       end}
     }
     ]
    }.

misc_test_() ->
    {setup,
     fun() -> ok end ,
     fun(_) -> ok end,
     [{"Conversion of a solution to binary",
       fun() ->
               Soln = [5936046,6000450,9980569,10770186,11256679,11557293,
                       12330374,16556162,25308926,27241299,29693321,31019885,
                       38091840,44351975,46970870,55597976,57712943,76763622,
                       78513115,78670397,82776188,82841920,84299614,86421603,
                       87878232,87913313,92453652,93430969,94032236,94428148,
                       97119256,102408900,104747553,108943266,112048126,
                       112561693,118817859,118965199,121744219,122178237,
                       132944539,133889045],
               NodeSize = ?TEST_MODULE:get_node_size(),
               ?debugFmt("node_t size: ~p~n", [NodeSize]),
               ?assertEqual(42*NodeSize, size(?TEST_MODULE:solution_to_binary(
                                                 lists:sort(Soln), NodeSize * 8, <<>>)))
       end}
     ]
    }.

-endif.
