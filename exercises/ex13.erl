-module(ex13).
-export([my_spawn1/3, my_spawn2/3, my_spawn3/4, sleeper/1]).

my_spawn1(Mod, Func, Args) ->
    statistics(wall_clock), %% calles to create a startTime

	Pid = spawn(Mod, Func, Args),
	Ref = monitor(process, Pid),
	receive
    	{'DOWN', Ref, process, Pid, Why} ->
        	io:format("~p died with: ~p~n",[Pid, Why]),
    		{_, RunTime} = statistics(wall_clock),
    		io:format("Ran for = ~p milliseconds~n",[RunTime])
	end.

my_spawn2(Mod, Func, Args) ->
    Pid = spawn(Mod, Func, Args),
    on_exit(Pid, fun(Why) -> io:format(" ~p died with:~p~n",[Pid, Why]) end).

my_spawn3(Mod, Func, Args, Time) ->
	statistics(wall_clock), %% calles to create a startTime

	{Pid, Ref} = spawn_monitor(Mod, Func, Args),

	receive
    	{'DOWN', Ref, process, Pid, Why} ->
        	io:format(" ~p died with: ~p~n",[Pid, Why]),
        	{_, RunTime} = statistics(wall_clock),
		    io:format("Ran for = ~p milliseconds~n",[RunTime])
		after Time ->
			exit(Pid, terminated),
			io:format("Terminated")
	end.

sleeper(SleepTimeInMilliseconds) ->
	timer:sleep(SleepTimeInMilliseconds),
	exit("Felt like it").

on_exit(Pid, Fun) ->
	spawn(fun() ->
			statistics(wall_clock),
			Ref = monitor(process, Pid),
				receive
            		{'DOWN', Ref, process, Pid, Why} ->
                    	Fun(Why),
                    	{_, RunTime} = statistics(wall_clock),
                    	io:format("Ran for =~p milliseconds~n",[RunTime])
				end
			end).


%% Exercises

%% 4. Write a function that creates a registered process that writes out "I'm still running" every five seconds.
%% Write a function that monitors this process and restarts it if it dies.
%% Start the global process and the monitor process. Kill the global process and check that it has been restarted by the monitor process.

%% 5. Write a function that starts and monitors several worker processes.
%% If any of the worker processes dies abnormally, restart it.

%% 6. Write a function that starts and monitors several worker processes.
%% If any of the worker processes dies abnormally, kill all the worker processes and restart them all.


