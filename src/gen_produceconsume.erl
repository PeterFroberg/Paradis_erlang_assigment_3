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
    %%Consumer
    {Pid, get, Ref, T} when Buffersize > 0 ->
      Pid ! {Ref, Callback, H},
      buffer(Callback, MaxTasks, T, Buffersize -1);
    %%Producer
    {Pid, put, Ref, T} when Buffersize < T ->
      {ok,NewTask} = Callback:handle_produce(T),
      buffer(Callback, MaxTasks, [Buffer|[NewTask]], Buffersize +1),
      Pid ! {Ref, ok}
  end.


stop(Pid) ->
  ok.

produce(Pid, T) ->
  Ref = make_ref(),
  Pid ! {self(), put, Ref, T},
  receive
    {Ref, ok} ->
      ok
  end.

consume(Pid) ->
  Ref = make_ref(),
  Pid ! {self(), get, Ref},
  receive
    {Ref, Callback, Task} ->
      Callback:handle_consume(Task)
  end.
