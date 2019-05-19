-module(condorcet_election).

%% API exports
-export([
    rankings/1,
    winner/1
]).

-include("include/elections.hrl").

%%====================================================================
%% API functions
%%====================================================================

-spec rankings([ballot(), ...]) -> [name(), ...].
rankings(Ballots) ->
    Prefs  = preferences(Ballots),
    Ranked = candidate:rank(Prefs),
    [ candidate:name(C) || C <- Ranked ].

-spec winner([ballot(), ...]) -> name().
winner(Ballots) -> hd(rankings(Ballots)).

%%====================================================================
%% Internal functions
%%====================================================================
-spec add_preferences([candidate(), ...],
                      map()) -> preferences().
add_preferences([_LastPlaceCand], Acc) -> Acc;

add_preferences([Cand | Rest], AccIn) ->
    Add = fun(C, Acc) -> increment_vote_count(Cand, C, Acc) end,
    Acc = lists:foldl(Add, AccIn, Rest),
    add_preferences(Rest, Acc).

-spec increment_vote_count(candidate(),
                           candidate(),
                           preferences()) -> preferences().
increment_vote_count(Cand, Next, PrefsIn) ->
    WithCount   = maps:get(Cand, PrefsIn),
    Count       = maps:get(Next, WithCount),
    Incremented = maps:put(Next, Count+1, WithCount),
    maps:put(Cand, Incremented, PrefsIn).

-spec preferences(list()) -> preferences().
preferences(Ballots) ->
    WithZeroCounts = with_zero_counts(Ballots),
    preferences(Ballots, WithZeroCounts).

-spec preferences(list(), map()) -> preferences().
preferences([],            Acc)   -> Acc;
preferences([Ballot | Bs], AccIn) ->
    Candidates = ballot:candidates(Ballot),
    Acc = add_preferences(Candidates, AccIn),
    preferences(Bs, Acc).

with_zero_counts(Ballots) ->
    AllCandidates = [C || B <- Ballots, C <- ballot:candidates(B)],
    UniqueCandidates = lists:usort(AllCandidates),
    lists:foldl(fun(Cand, Acc) ->
                    Others = lists:delete(Cand, UniqueCandidates),
                    ZC = zero_counts(Others, Acc),
                    maps:put(Cand, ZC, Acc)
                end,
    maps:new(),
    UniqueCandidates).

zero_counts([],            Acc) -> Acc;
zero_counts([Next | Rest], Acc) -> zero_counts(Rest, maps:put(Next, 0, Acc)).
