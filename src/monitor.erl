%%%-------------------------------------------------------------------
%%% @author Peter
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. mars 2020 10:23
%%%-------------------------------------------------------------------
-module(monitor).
-author("Peter").

%% API
-export([start/0, init/1]).
-behavior(supervisor).

start() ->
  supervisor:start_link(?MODULE,[]).

init(_) ->
  SupFlags = #{strategy => one_for_one,
    intensity => 5,
    period => 5},
  ChildSpec = [#{id => double_id,
    start => {double, start,[]}}],
  {ok,{SupFlags,ChildSpec}}.