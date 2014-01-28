-module(ex13).
-export([my_spawn1/3, my_spawn2/3, my_spawn3/4, sleeper/1, i_am_alive/0, i_am_alive1/0, i_am_alive2/0, i_am_alive3/0, monitor/0, start/0, restart_worker1/0, keep_alive/4, on_exit/2]).

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

i_am_alive() ->
	receive
		after 5000 ->
			io:format("( ~p ) I am alive.~n", [self()]),
			i_am_alive()
	end.

i_am_alive1() ->
	receive
		after 4000 ->
			io:format("( ~p ) I am alive (1).~n", [self()]),
			i_am_alive1()
	end.

i_am_alive2() ->
	receive
		after 5000 ->
			io:format("( ~p ) I am alive (2).~n", [self()]),
			i_am_alive2()
	end.

i_am_alive3() ->
	receive
		after 6000 ->
			io:format("( ~p ) I am alive (3).~n", [self()]),
			i_am_alive3()
	end.

monitor() ->
	Ref = erlang:monitor(process, alive),
	receive
		{'DOWN', Ref, process, _, _} ->
			io:format("Restart~n"),
			start(),
			monitor()
	end.

start() ->
	Pid = spawn(ex13, i_am_alive, []),
	register(alive, Pid).

keep_alive(Name, Mod, Fun, Args) ->
	register(Name, Pid = spawn(Mod, Fun, Args)),
	on_exit(Pid, fun(_Why) -> keep_alive(Name, Mod, Fun, Args) end).

restart_worker1() ->
	keep_alive(alive1, ex13, i_am_alive1, []),
	keep_alive(alive2, ex13, i_am_alive2, []),
	keep_alive(alive3, ex13, i_am_alive3, []).

