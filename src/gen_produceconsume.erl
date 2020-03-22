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

-callback handle_produce(T::term()) ->
{ok, Task}.

-callback handle_consume(T::term()) ->
  ok.

start(Callback, T) ->
  spawn(fun() -> buffer(Callback,T) end).

buffer(Callback, MaxTasks, Buffer, Buffersize) ->
  [H|T] = Buffer,
  receive
    {Pid, get, Ref, T} when Buffersize > 0 ->
      Pid ! {Ref, Callback:handle_consume(T)},
      buffer(Callback, MaxTasks, T, Buffersize -1);

    {Pid, put, Ref, T} when Buffersize < T ->
      NewTask = Callback:handle_produce(T),
      buffer(Callback, MaxTasks, [Buffer|[NewTask]], Buffersize +1)
  end.


stop(Pid) ->
  ok.

produce(Pid, T) ->
  Ref = make_ref(),
  Pid ! {self(), Ref, T},
  receive
    {Ref} ->
      ok
  end,
  ok.

consume(Pid) ->
  ok.
