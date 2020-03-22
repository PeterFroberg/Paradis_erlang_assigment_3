%%%-------------------------------------------------------------------
%%% @author Peter
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. mars 2020 11:06
%%%-------------------------------------------------------------------
-module(ring).
-author("Peter").

%% API
-export([start/2]).

start(N, M) ->
  register(start, self()),
  [H | T] = createRingNode(N, []),
  Nodes = T ++ [H],
  Ref = make_ref(),
  H ! {Nodes, 0, N * M, Ref},
  receive
    {Value, Ref} ->
      [exit(I, kill) || I <- Nodes],
      unregister(start),
      Value
  end.

createRingNode(0, Nodes) ->
  Nodes;

createRingNode(N, Nodes) ->
  Pid = spawn(fun() -> ringNode() end),
  createRingNode(N - 1, [Pid | Nodes]).

ringNode() ->
  receive
    {[_H | _T], Value, 0, Ref} ->
      whereis(start) ! {Value, Ref},
      ringNode();

    {[H | T], Value, RemainingNodes, Ref} ->
      H ! {T ++ [H], Value + 1, RemainingNodes - 1, Ref},
      ringNode()
  end.

