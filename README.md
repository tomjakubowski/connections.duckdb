# connections.duckdb

**Be wary**: this README contains **spoilers** for the New York Times
Connections puzzle for 2026-02-26 and 2026-02-27 in America/New_York time.

[DuckDB][] is already more fun than a barrel of ducks on its own.  But
sometimes the toil of crunching entities leaves you wanting a little side
quest, a diversion.  What if you could take a break and play the [New York Times
Connections] puzzle, all without leaving your DuckDB REPL?

Introducing the first database that lets you play the New York Times
Connections puzzle: `connections.duckdb`.

## How to play

Start DuckDB with the database loaded, either by downloading a release or using
the convenient hosted version:

```bash
$ duckdb https://www.tjak.dev/connections.duckdb
```

From within a REPL:

```duckdb
D ATTACH 'https://www.tjak.dev/connections.duckdb' as connections (READ_ONLY);
D USE connections;
```

See today's words:

```duckdb
D select word from todays_words;
┌────────────┐
│    word    │
│  varchar   │
├────────────┤
│ JUDAS      │
│ DRILL      │
│ QUALITY    │
│ BUTTERFLY  │
│ FRENCH     │
│ BENCH      │
│ AIR        │
│ RIPPLE     │
│ SNAKE      │
│ SNOWBALL   │
│ TRAITOR    │
│ MANNER     │
│ DOMINO     │
│ PRINTING   │
│ IMPRESSION │
│ TURNCOAT   │
├────────────┤
│  16 rows   │
└────────────┘
```

See today's puzzle formatted in a 4x4 grid:

```duckdb
D select * from todays_puzzle;
┌─────────┬──────────┬────────────┬───────────┐
│  word1  │  word2   │   word3    │   word4   │
│ varchar │ varchar  │  varchar   │  varchar  │
├─────────┼──────────┼────────────┼───────────┤
│ JUDAS   │ DRILL    │ QUALITY    │ BUTTERFLY │
│ FRENCH  │ BENCH    │ AIR        │ RIPPLE    │
│ SNAKE   │ SNOWBALL │ TRAITOR    │ MANNER    │
│ DOMINO  │ PRINTING │ IMPRESSION │ TURNCOAT  │
└─────────┴──────────┴────────────┴───────────┘
```

Group four words into a category, and then check your guess.  If incorrect, the
query will return no rows.  If correct, the query will return the category's
title.

```duckdb
D SELECT * FROM guess_category_today(['JUDAS', 'DRILL', 'QUALITY', 'BUTTERFLY']);
┌─────────┐
│  title  │
│ varchar │
├─────────┤
│ 0 rows  │
└─────────┘
D SELECT * FROM guess_category_today(['IMPRESSION', 'AIR', 'QUALITY', 'MANNER']);
┌─────────┐
│  title  │
│ varchar │
├─────────┤
│ AURA    │
└─────────┘
```

You're on your own to keep the score and keep yourself honest.  Check back soon
for automated scorekeeping!

## How to cheat

See the categories for today's puzzle:

```duckdb
D select title as category, unnest(cards).content as word from todays_categories;
┌───────────────────────────────────┬────────────┐
│             category              │    word    │
│              varchar              │  varchar   │
├───────────────────────────────────┼────────────┤
│ BACKSTABBER                       │ JUDAS      │
│ BACKSTABBER                       │ SNAKE      │
│ BACKSTABBER                       │ TRAITOR    │
│ BACKSTABBER                       │ TURNCOAT   │
│ AURA                              │ AIR        │
│ AURA                              │ IMPRESSION │
│ AURA                              │ MANNER     │
│ AURA                              │ QUALITY    │
│ KINDS OF CHAIN REACTION "EFFECTS" │ BUTTERFLY  │
│ KINDS OF CHAIN REACTION "EFFECTS" │ DOMINO     │
│ KINDS OF CHAIN REACTION "EFFECTS" │ RIPPLE     │
│ KINDS OF CHAIN REACTION "EFFECTS" │ SNOWBALL   │
│ ___ PRESS                         │ BENCH      │
│ ___ PRESS                         │ DRILL      │
│ ___ PRESS                         │ FRENCH     │
│ ___ PRESS                         │ PRINTING   │
├───────────────────────────────────┴────────────┤
│ 16 rows                              2 columns │
└────────────────────────────────────────────────┘
```

See the categories for the puzzle from date `2026-02-26`:

```duckdb
D select title as category, unnest(cards).content as word from connections_categories('2026-02-26');
┌──────────────────────────┬───────────────────┐
│         category         │       word        │
│         varchar          │      varchar      │
├──────────────────────────┼───────────────────┤
│ PIVOTAL POINT            │ CROSSROADS        │
│ PIVOTAL POINT            │ LANDMARK          │
│ PIVOTAL POINT            │ MILESTONE         │
│ PIVOTAL POINT            │ WATERSHED         │
│ GREEN THINGS             │ GRASSHOPPER       │
│ GREEN THINGS             │ SHAMROCK          │
│ GREEN THINGS             │ STATUE OF LIBERTY │
│ GREEN THINGS             │ WASABI            │
│ ELEMENTS OF JOKE-TELLING │ CALLBACK          │
│ ELEMENTS OF JOKE-TELLING │ PUNCHLINE         │
│ ELEMENTS OF JOKE-TELLING │ SETUP             │
│ ELEMENTS OF JOKE-TELLING │ TIMING            │
│ "___ PLEASE"             │ ATTENTION         │
│ "___ PLEASE"             │ CHECK             │
│ "___ PLEASE"             │ DRUMROLL          │
│ "___ PLEASE"             │ PRETTY            │
├──────────────────────────┴───────────────────┤
│ 16 rows                            2 columns │
└──────────────────────────────────────────────┘
```

## How it works (data disclaimer)

`connections.duckdb` contains no data from the New York Times.  Instead, it
contains code, in the form of DuckDB-flavored SQL macros and views, which
provide convenient access to the game's publicly accessible data feed through
DuckDB's `read_json` function.  Invoking this code from a DuckDB connection
attached to the database allows the connected user or agent to play the
Connections game locally using data resident in-memory.

# copyright

source code (c) 2026 Tom Jakubowski, published under the MIT licensed

I am a happy player and admirer of the [Connections] game which is owned by the
New York Times and edited by Wyna Liu.

[DuckDB]: <https://duckdb.org/>
[New York Times Connections]: <https://www.nytimes.com/games/connections>
[Connections]: <https://www.nytimes.com/games/connections>