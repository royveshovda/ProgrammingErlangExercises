-module(ex12).

-export([start/2, max/1, max/0, wait/0, wait_for_message/1, max_ring/2]).

start(AnAtom, Fun) ->
	undefined = whereis(AnAtom),
	Pid = spawn(Fun),
	register(AnAtom, Pid),
    Pid.

max() ->
    max(100000).

%% max(N) 

%%   Create N processes then destroy them
%%   See how much time this takes
max(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n",[Max]),
    statistics(runtime),
    statistics(wall_clock),
    L = for(1, N, fun() -> spawn(fun() -> wait() end) end),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    lists:foreach(fun(Pid) -> Pid ! die end, L),
    U1 = Time1 * 1000 / N,
    U2 = Time2 * 1000 / N,
    io:format("Process spawn time=~p (~p) microseconds~n",
	      [U1, U2]).

wait() ->
    receive
	die -> void
    end.

for(N, N, F) -> [F()];
for(I, N, F) -> [F()|for(I+1, N, F)].

%% Write a ring benchmark. Create N processes in a ring. Send a message round in a ring M times so that a total of N * M messages get sent.
%% Time how long this takes for different values of N and M.

%% TODO: Make measurements

max_ring(Processes, Messages) ->
    Pid0 = self(),
    PidStart = for_spawn(Pid0, Processes, Processes),
    io:format("All spawned~n"),

    pass_messages(PidStart, Messages),
    
    PidStart ! die,
    receive
        die -> io:format("Die received~n")
    end,
    io:format("Done!~n").

for_spawn(PidToPassOnTo, 1, _) ->
    PidToReturn = spawn(fun() -> wait_for_message(PidToPassOnTo) end),
    PidToReturn;
for_spawn(PidToPassOnTo, Number, Max) ->
    NewPid = spawn(fun() -> wait_for_message(PidToPassOnTo) end),
    for_spawn(NewPid, Number-1, Max).

pass_messages(PidStart, 0) ->
    pass_message(PidStart);
pass_messages(PidStart, Messages) ->
    pass_message(PidStart),
    io:format("Ping~n"),
    pass_messages(PidStart, Messages-1).

pass_message(PidStart) ->
    PidStart ! pass,
    receive
        pass -> io:format("Token received~n")
    end.
    

%% Function to spawn and connect N processes
%% Function to time and send M messages

wait_for_message(PidToPassOnTo) ->
    receive
        die ->
            PidToPassOnTo ! die;
        pass ->
            PidToPassOnTo ! pass, wait_for_message(PidToPassOnTo)
        end.


