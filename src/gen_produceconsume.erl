%%%-------------------------------------------------------------------
%%% @author Peter
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. mars 2020 21:09
%%%-------------------------------------------------------------------
-module(gen_produceconsume).
-author("Peter").

%% API
-export([start/2, stop/1, produce/2, consume/1]).

-callback handl_produce(T::term()) ->
{ok, Task}.

-callback handle_consume(Pid::term()) ->
  ok.

start(Callback, T) ->
  ok.

stop(Pid) ->
  ok.

produce(Pid, T) ->
  Callback:handel_produce(T),
  ok.

consume(Pid) ->
  ok.
