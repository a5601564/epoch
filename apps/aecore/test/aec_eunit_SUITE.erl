-module(aec_eunit_SUITE).

-export([all/0, groups/0, suite/0,
         init_per_suite/1, end_per_suite/1,
         init_per_group/2, end_per_group/2,
         init_per_testcase/2, end_per_testcase/2
        ]).

-include_lib("common_test/include/ct.hrl").
-compile({parse_transform, ct_eunit_xform}).

all() ->
    [{group, eunit}].

groups() ->
    [].

suite() ->
    [].

init_per_suite(Config) ->
    eunit:start(),
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_Grp, Config) ->
    Config.

end_per_group(_Grp, _Config) ->
    ok.

init_per_testcase(_TC, Config) ->
    Apps = application:which_applications(),
    Names = registered(),
    [{running_apps, Apps},
     {regnames, Names}|Config].

end_per_testcase(_TC, Config) ->
    Apps0 = ?config(running_apps, Config),
    Names0 = ?config(regnames, Config),
    Apps = application:which_applications(),
    Names = registered() -- [cover_server, timer_server],
    case {(Apps -- Apps0), Names -- Names0} of
      {[], []} -> 
        ok;
      {NewApps, _} when NewApps =/= [] ->
        %% New applications take precedence over new registered processes
        {fail, {started_applications, NewApps}};
      {_, NewReg} -> 
        {fail, {registered_processes, NewReg}}
    end.

