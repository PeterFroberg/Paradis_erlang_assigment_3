%%%-------------------------------------------------------------------
%%% @author Peter
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. mars 2020 22:35
%%%-------------------------------------------------------------------
-module(test).
-behaviour(gen_produceconsume).
-export([handle_produce/1, handle_consume/1, test/0]).

handle_produce(N) ->
  {ok, N}.

handle_consume({task, N}) ->
  io:format("Consuming: ~p~n", [N]),
  ok.

test() ->
  P = gen_produceconsume:start(?MODULE, 3),
  io:format("P: ~p \n",[P]),
  spawn(fun () -> lists:foreach(
    fun (I) ->
      gen_produceconsume:produce(P, I)
    end, lists:seq(1, 10))
        end),
  spawn(fun () -> lists:foreach(
    fun (_) ->
      gen_produceconsume:consume(P)
    end, lists:seq(1, 10))
        end),
  ok.