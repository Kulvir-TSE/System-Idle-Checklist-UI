#!/usr/bin/env escript

main(_) ->
    net_kernel:start([shell, shortnames]),
    erlang:set_cookie(node(), butler_server),



    %io:format("~nData Sanity Check 1: "),
    DataSanityCheck1 = rpc:call(butler_server@localhost, mhs_api_utils, run_data_domain_and_sanity_checks, [true]),
    %io:format("~p~n", [DataSanityCheck1]),

    %io:format("~nData Sanity Check 2: "),
    DataSanityCheck2 = rpc:call(butler_server@localhost, data_domain_validation_functions, validate_all_tables, [true]),
    %io:format("~p~n", [DataSanityCheck2]),


    {ActivePutOutputs, ActiveOrders, ActiveAudits, ActiveAuditLines, ActivePickInstructions,
     EligiblePPSStations, PendingPPSTasks, PendingAuditTasks, PendingPostpickTasks, 
     PendingMoveTasks, NotIdleBins, NotToteinbin, Status} = fetch_data(),

    
    %% Fetch all scheduled jobs and save them to a text file
    case rpc:call(butler_server@localhost, erlcron, get_all_jobs, []) of
        List when is_list(List) ->
            JobCount = length(List),
            file:write_file("/home/gor/SystemIdle/texts/Scheduled_Jobs", iolist_to_binary(io_lib:format("Scheduled Jobs Count: ~p~nScheduled Jobs: ~p~n", [JobCount, List]))),
            io:format("Scheduled Jobs Count: ~p (Saved to Scheduled_Jobs)~n", [JobCount]);

        Error ->
            file:write_file("/home/gor/SystemIdle/texts/Scheduled_Jobs", "Failed to fetch scheduled jobs\n"),
            %io:format("~p~n", [Error])
    end,

    save_data_to_file("Active-PPSs", length(EligiblePPSStations), EligiblePPSStations),
    save_data_to_file("Idle-Bins", length(NotIdleBins), NotIdleBins),
    save_data_to_file("Totes-Attached-Bins", length(NotToteinbin), NotToteinbin),
    save_data_to_file("NO-Orders-Data", length(ActiveOrders), ActiveOrders),
    save_data_to_file("NO-Put-Outputs", length(ActivePutOutputs), ActivePutOutputs),
    save_data_to_file("NO-Pick-Instructions", length(ActivePickInstructions), ActivePickInstructions),
    save_data_to_file("NO-Audits", length(ActiveAudits), ActiveAudits),
    save_data_to_file("NO-Audit-Lines", length(ActiveAuditLines), ActiveAuditLines,Status),
    save_data_to_file("NO-PPS-Tasks", length(PendingPPSTasks), PendingPPSTasks),
    save_data_to_file("NO-Audit-Tasks", length(PendingAuditTasks), PendingAuditTasks),
    save_data_to_file("NO-Post-Pick-Tasks", length(PendingPostpickTasks), PendingPostpickTasks),
    save_data_to_file("NO-Move-Tasks", length(PendingMoveTasks), PendingMoveTasks),
    save_data_to_file("Data-Sanity-MHS", DataSanityCheck1),
    save_data_to_file("Data-Sanity-Validate", DataSanityCheck2).


fetch_data() ->
    {ok, ActivePutOutputs} = rpc:call(butler_server@localhost, put_output1, search_by, [[{status, notequal, completed}], key]),
    {ok, ActiveOrders} = rpc:call(butler_server@localhost, order_node, search_by, [[{status, notin, [complete, abandoned, cancelled, unfulfillable, created]}], key]),
    {ok, ActiveAudits} = rpc:call(butler_server@localhost, auditrec, search_by, [[{status, notin, [audit_aborted, audit_completed, audit_resolved, audit_reaudited, audit_cancelled, audit_created]}], key]),
    {ok, ActiveAuditLines} = rpc:call(butler_server@localhost, auditlinerec1, search_by, [[{status, notin, [audit_completed, audit_resolved, audit_reaudited, audit_cancelled, audit_created]}], key]),
    {ok, ActiveAuditLinesStatus} = rpc:call(butler_server@localhost, auditlinerec1, search_by, [[{status, notin, [audit_completed, audit_resolved, audit_reaudited, audit_cancelled, audit_created]}], [status]]),
    Status=lists:usort(lists:flatten(ActiveAuditLinesStatus)),
    {ok, ActivePickInstructions} = rpc:call(butler_server@localhost, pick_instruction, search_by, [[{status, notequal, complete}], key]),
    EligiblePPSStations = rpc:call(butler_server@localhost, ppsnode, get_eligible_pps, [[pick, put, audit]]),
    {ok, PendingPPSTasks} = rpc:call(butler_server@localhost, ppstaskrec, search_by, [[{status, notequal, complete}], key]),
    {ok, PendingAuditTasks} = rpc:call(butler_server@localhost, audittaskrec, search_by, [[{status, notequal, complete}], key]),
    {ok, PendingPostpickTasks} = rpc:call(butler_server@localhost, postpicktaskrec, search_by, [[{status, notequal, complete}], key]),
    {ok, PendingMoveTasks} = rpc:call(butler_server@localhost, movetaskrec, search_by, [[{status, notequal, complete}], key]),
    {ok, NotIdleBins} = rpc:call(butler_server@localhost, ppsbinrec, search_by, [[{status, notequal, idle}, {status, notequal, inactive}], [bin_info,status,sr_ids]]),
    {ok, NotToteinbin} = rpc:call(butler_server@localhost, ppsbinrec, search_by, [[{totes_associated,notequal,[]}], [bin_info,status,sr_ids,totes_associated]]),

    {ActivePutOutputs, ActiveOrders, ActiveAudits, ActiveAuditLines, ActivePickInstructions,
     EligiblePPSStations, PendingPPSTasks, PendingAuditTasks, PendingPostpickTasks, 
     PendingMoveTasks, NotIdleBins, NotToteinbin, Status}.

save_data_to_file(Filename, Data) ->
    Content = io_lib:format("~p~n", [Data]),
    FilePath = "/home/gor/SystemIdle/texts/" ++ Filename,
    file:write_file(FilePath, iolist_to_binary(Content)).

%% Function to save count + values to a file
save_data_to_file(Filename, Count, Data) ->
    Content = io_lib:format("~p~n~p~n", [Count, Data]),
    FilePath = "/home/gor/SystemIdle/texts/" ++ Filename,
    file:write_file(FilePath, iolist_to_binary(Content)).


save_data_to_file(Filename, Count, Data, Status) ->
    Content = io_lib:format("~p~n~p~n~p~n", [Count, Status, Data]),
    FilePath = "/home/gor/SystemIdle/texts/" ++ Filename,
    file:write_file(FilePath, iolist_to_binary(Content)).
