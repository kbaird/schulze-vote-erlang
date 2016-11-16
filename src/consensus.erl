-module(consensus).

%% API exports
-export([
    cabinet_composition/2,
    effective_num_parties/1,
    schulze_rankings/1,
    schulze_winner/1
]).

-include("parties.hrl").
-include("schulze.hrl").

%%====================================================================
%% API functions
%%====================================================================

% Cf. Lijphart, Arend, _Patterns of Democracy_, 1999. pg93.
-spec cabinet_composition(atom(), [{party_name(), seat_share()}, ...]) ->
    [party_name(), ...].
cabinet_composition(bargaining_proposition, SeatShares) ->
    cabinet_composition(bp, SeatShares);
cabinet_composition(bp, _SeatShares) ->
    [];
cabinet_composition(minimal_connected_winning, SeatShares) ->
    cabinet_composition(mcw, SeatShares);
cabinet_composition(minimum_connected_winning, SeatShares) ->
    cabinet_composition(mcw, SeatShares);
cabinet_composition(mcw, _SeatShares) ->
    [];
cabinet_composition(minimal_range, SeatShares) ->
    cabinet_composition(mr, SeatShares);
cabinet_composition(minimum_range, SeatShares) ->
    cabinet_composition(mr, SeatShares);
cabinet_composition(mr, _SeatShares) ->
    [];
cabinet_composition(minimal_winning_coalition, SeatShares) ->
    cabinet_composition(mwc, SeatShares);
cabinet_composition(minimum_winning_coalition, SeatShares) ->
    cabinet_composition(mwc, SeatShares);
cabinet_composition(mwc, _SeatShares) ->
    [[]];
cabinet_composition(minimal_size, SeatShares) ->
    cabinet_composition(ms, SeatShares);
cabinet_composition(minimum_size, SeatShares) ->
    cabinet_composition(ms, SeatShares);
cabinet_composition(ms, SeatShares) ->
    Cabs    = cabinet_composition(mwc, SeatShares),
    Sizes   = [ length(C) || C <- Cabs ],
    [ MinSize | _ ] = lists:sort(Sizes),
    [ SmallestCab || SmallestCab <- Cabs,
                     length(SmallestCab) =:= MinSize ];
cabinet_composition(policy_viable_coalition, SeatShares) ->
    cabinet_composition(pvc, SeatShares);
cabinet_composition(pvc, _SeatShares) ->
    [].

% Implement Markku Laakso and Rein Taagepera's index as described in
% Arend Lijphart's Patterns of Democracy (1999), pp67-68.

% Laakso, Markku and Rein Taagepera. 1979.
% "'Effective' Number of Parties: A Measure with Application to West Europe."
% _Comparative Political Studies_ 12, no. 1 (April): 3-27.
% http://cps.sagepub.com/content/12/1/3.extract
-spec effective_num_parties([{party_name(), seat_share()}, ...]) -> number().
effective_num_parties(PartyShares) -> 1 / sum_for(PartyShares).

-spec schulze_rankings([ballot(), ...]) -> [name(), ...].
schulze_rankings(Ballots) ->
    Prefs      = preferences(Ballots, #{}),
    Candidates = maps:keys(Prefs),
    Ranked     = schulze_candidate:rank(Candidates, Prefs),
    [ C#candidate.name || C <- Ranked ].

-spec schulze_winner([ballot(), ...]) -> name().
schulze_winner(Ballots) -> hd(schulze_rankings(Ballots)).

%%====================================================================
%% Internal functions
%%====================================================================

add_preferences(_Cand, [], Acc) -> Acc;
add_preferences(Cand,  [ Next | Rest ], AccIn) ->
    Acc1 = increment_vote_count(Cand, Next, AccIn),
    Acc2 = add_preferences(Cand, Rest, Acc1),
    add_preferences(Next, Rest, Acc2).

increment_vote_count(Cand, Next, PrefsIn) ->
    WithCount   = maps:get(Cand, PrefsIn, maps:new()),
    Count       = maps:get(Next, WithCount, 0),
    Incremented = maps:put(Next, Count+1, WithCount),
    maps:put(Cand, Incremented, PrefsIn).

-spec preferences(list(), map()) -> map().
preferences([], Acc)              -> Acc;
preferences([Ballot | Bs], AccIn) ->
    [ Cand | Rest ] = Ballot#ballot.candidates,
    case Rest of
        [] -> maps:put(Cand, winner, maps:new());
        _  -> Acc = add_preferences(Cand, Rest, AccIn),
              preferences(Bs, Acc)
    end.

sum_for(PartyShares) ->
    lists:foldl(fun sum_share_squares/2, 0, PartyShares).

sum_share_squares({_, Share}, Sum) -> (Share * Share) + Sum.
