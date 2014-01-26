-module(ex13).
-export([my_spawn/3, sleeper/1]).

my_spawn(Mod, Func, Args) ->
    statistics(wall_clock), %% calles to create a startTime

	{Pid, Ref} = spawn_monitor(Mod, Func, Args),
	receive
    	{'DOWN', Ref, process, Pid, Why} ->
        	io:format(" ~p died with:~p~n",[Pid, Why])
	end,
    {_, Time} = statistics(wall_clock),
    io:format("Ran for =~p milliseconds~n",[Time]).


sleeper(SleepTimeInMilliseconds) ->
	timer:sleep(SleepTimeInMilliseconds),
	exit("Felt like it").

%% Exercises
%% DONE: 1. Write a function my_spawn(Mod, Func, Args) that behaves like spawn(Mod, Func, Args) but with one difference.
%% If the spawned process dies, a message should be printed saying why the process died and how long the process lived for before it died.

%% 2. Solve the previous exercise using the on_exit function shown earlier in this chapter.

%% 3. Write a function my_spawn(Mod, Func, Args, Time) that behaves like spawn(Mod, Func, Args) but with one difference.
%% If the spawned process lives for more than Time seconds, it should be killed.

%% 4. Write a function that creates a registered process that writes out "I'm still running" every five seconds.
%% Write a function that monitors this process and restarts it if it dies.
%% Start the global process and the monitor process. Kill the global process and check that it has been restarted by the monitor process.

%% 5. Write a function that starts and monitors several worker processes.
%% If any of the worker processes dies abnormally, restart it.

%% 6. Write a function that starts and monitors several worker processes.
%% If any of the worker processes dies abnormally, kill all the worker processes and restart them all.