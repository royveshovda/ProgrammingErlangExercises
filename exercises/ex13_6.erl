-module(ex13_6).
-compile(export_all).

start() ->
	Pid = spawn(ex13_6, loop, [[]]),
	register(ex_13_6, Pid),
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [4000,1], alive1},
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [5000,2], alive2},
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [6000,3], alive3},
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [7000,4], alive4},
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [8000,5], alive5},
	Pid ! {register, ex13_6, i_am_alive_with_timeout, [9000,6], alive6},
	io:format("Running~n").

stop() ->
	ex_13_6 ! {stop,self()},
	receive
		stop ->
			io:format("Loop stopped~n")
	after
		5000 ->
			io:format("Process did not respond with stop~n")
	end,
	io:format("Exited OK~n").



loop(Processes) ->	
	receive
		{stop, Pid} ->
			io:format("stop loop~n"),
			stop_all(Processes),
			Pid ! stop;
		{register, Module, Fun, Args, Name} ->
			Pid = spawn(Module, Fun, Args),
			register(Name, Pid),
			on_exit(self(), Pid),
			loop([{Pid, Module, Fun, Args, Name} | Processes]);
        restart_all ->
        	NewProcessList = restart_all_workers(Processes, []),
        	loop(NewProcessList);
		Any ->
			io:format("Received:~p~n",[Any]),
			loop(Processes)
	end.


sleeper(SleepTimeInMilliseconds) ->
	timer:sleep(SleepTimeInMilliseconds),
	exit("Felt like it").

on_exit(MonitorId, Pid) ->
	spawn(fun() ->
			Ref = monitor(process, Pid),
				receive
					{'DOWN', Ref, process, Pid, stop} ->
                    	io:format("Exit submonitor (stop)~n");
                    {'DOWN', Ref, process, Pid, restart} ->
                    	io:format("Exit submonitor (restart)~n");
            		{'DOWN', Ref, process, Pid, _Why} ->
                    	io:format("Exit submonitor (trigger restart for all)~n"),
                    	MonitorId ! restart_all
				end
			end).

i_am_alive_with_timeout(SleepTimeInMilliseconds, Number) ->
	receive
		after SleepTimeInMilliseconds ->
			io:format("( ~p ) I am alive (~p).~n", [self(), Number]),
			i_am_alive_with_timeout(SleepTimeInMilliseconds, Number)
	end.

restart_all_workers([], NewProcesses) ->
	NewProcesses;
restart_all_workers([{Pid, Module, Fun, Args, Name} | Process_list], NewProcesses) ->
	exit(Pid, restart),
	io:format("Name: ~p~n", [Name]),

	% This is a nasty workaround.
	% But in a normal case we would not need to register the process, and the problem would not exist in the first place.
	receive after 1000 -> void end,

	NewPid = spawn(Module, Fun, Args),
	register(Name, NewPid),
	on_exit(self(), NewPid),
	restart_all_workers(Process_list, [{NewPid, Module, Fun, Args, Name} | NewProcesses]).

stop_all([]) ->
	ok;
stop_all([{Pid, _Module, _Fun, _Args, _Name} | Process_list]) ->
	exit(Pid, stop),
	stop_all(Process_list).

stop_test(ProcessName) ->
	Pid = whereis(ProcessName),
	exit(Pid, die).