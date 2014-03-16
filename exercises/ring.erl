-module(ring).

-export([start/3, wait_for_message/1]).


start(ProcNum, MsgNum, Message) ->
    Pid0 = self(),
    PidStart = for_spawn(Pid0, ProcNum, ProcNum),
    io:format("Chain formed~n"),
    pass_messages(PidStart, MsgNum, Message),
    io:format("Messages passed~n"),
    PidStart ! die,
    receive
        die -> io:format("Die received~n")
    end.

for_spawn(PidToPassOnTo, 1, _) ->
    spawn(fun() -> wait_for_message(PidToPassOnTo) end);
for_spawn(PidToPassOnTo, Number, Max) ->
    NewPid = spawn(fun() -> wait_for_message(PidToPassOnTo) end),
    for_spawn(NewPid, Number-1, Max).

pass_messages(PidStart, 0, Message) ->
    pass_message(PidStart, Message);
pass_messages(PidStart, Messages, Message) ->
    pass_message(PidStart, Message),
    pass_messages(PidStart, Messages-1, Message).

pass_message(PidStart, Message) ->
    PidStart ! Message,
    receive
        Message ->void
    end.
    

%% Function to spawn and connect N processes
%% Function to time and send M messages

wait_for_message(PidToPassOnTo) ->
    receive
        die ->
            PidToPassOnTo ! die;
        Any ->
            PidToPassOnTo ! Any,
            wait_for_message(PidToPassOnTo)
        end.


