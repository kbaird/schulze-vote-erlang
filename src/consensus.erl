-module(consensus).

%% API exports
-export([
    cabinet_composition/2,
    condorcet_rankings/1,
    condorcet_winner/1,
    effective_num_parties/1,
    gallagher_index/1
]).

-include("parties.hrl").
-include("condorcet.hrl").

%%====================================================================
%% API functions
%%====================================================================

% Cf. Lijphart, Arend, _Patterns of Democracy_, 1999. pg93.
cabinet_composition(Label, SeatShares) ->
    consensus_cabinet:compose(Label, SeatShares).

condorcet_rankings(Ballots) ->
    condorcet_election:rankings(Ballots).

condorcet_winner(Ballots) ->
    condorcet_election:winner(Ballots).

% Implement Markku Laakso and Rein Taagepera's index as described in
% Arend Lijphart's Patterns of Democracy (1999), pp67-68. also
% Laakso, Markku and Rein Taagepera. 1979.
% "'Effective' Number of Parties: A Measure with Application to West Europe."
% _Comparative Political Studies_ 12, no. 1 (April): 3-27.
% http://cps.sagepub.com/content/12/1/3.extract
-spec effective_num_parties([party_result()]) -> number().
effective_num_parties(PartyShares) ->
    consensus_party:effective_number(PartyShares).

% Measure of disproportionality proposed by Michael Gallagher.
% Cf. Lijphart, Arend, _Patterns of Democracy_, 1999. pg158. and
% Gallagher, Michael. 1991. "Proportionality, Disproportionality, and
% Electoral systems." _Electoral Studies_ 10, no. 1 (March): 33-51.
-spec gallagher_index([party_result()]) -> number().
gallagher_index(ElectionResults) ->
    consensus_gallagher:index(ElectionResults).

