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

-callback handle_produce(T :: term()) ->
{ok, Task :: term}.

-callback handle_consume(T::term()) ->
  ok.

start(Callback, T) ->
  Pid = spawn(fun () -> buffer(Callback, T, [1,2], 0) end),
  Pid.

buffer(Callback, MaxTasks, [H|T] , Buffersize) ->
  receive
    %%Consumer
    {Pid, get, Ref, T} when Buffersize > 0 ->
      Pid ! {Ref, Callback, H},
      buffer(Callback, MaxTasks, T, Buffersize -1);
    %%Producer
    {Pid, put, Ref, T} when Buffersize < MaxTasks ->
      {ok,NewTask} = Callback:handle_produce(T),
      buffer(Callback, MaxTasks, [[H|T]|[NewTask]], Buffersize +1),
      Pid ! {Ref, ok}
  end.


stop(Pid) ->
  exit(Pid, kill).

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
