# lita-team-balance

[![Build Status](https://travis-ci.org/horozco/lita-team-balance.png?branch=master)](https://travis-ci.org/horozco/lita-team-balance)
[![Coverage Status](https://coveralls.io/repos/horozco/lita-team-balance/badge.png)](https://coveralls.io/r/horozco/lita-team-balance)

Set scores for members in the team to create two balanced teams from a given one. 

## Installation

Add lita-team-balance to your Lita instance's Gemfile:

``` ruby
gem "lita-team-balance"
```

## Usage

```
Lita: <name> team set <member> score <value(1-10)>  - Set the score for a member in the team
Lita: <name> team set my score <value(1-10)> - Set my score
```