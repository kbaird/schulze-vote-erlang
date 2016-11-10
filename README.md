# schulze-vote-erlang

An OTP library implementing the [Schulze voting
system](https://en.wikipedia.org/wiki/Schulze_method)

The [main non-trivial test
file](https://github.com/kbaird/schulze-vote-erlang/blob/master/test/tn_capital_test.erl)
uses the [TN Capital
example](https://en.wikipedia.org/wiki/Condorcet_method#Example:_Voting_on_the_location_of_Tennessee.27s_capital)
from Wikipedia.

## Build

    $ rebar3 compile

## Eunit

    $ rebar3 eunit

## Dialyzer

    $ rebar3 dialyzer

## Elvis

Download [elvis](https://github.com/inaka/elvis), then

    $ elvis rock

## TODO
- currently requires every ballot to be complete
