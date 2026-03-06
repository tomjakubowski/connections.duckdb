#!/usr/bin/env vhs

Output demo.gif
Require duckdb

Set FontSize 24
Set Width 1200
Set Height 600
Set Shell bash

Hide
Type 'PS1="> "' Enter
Type "clear" Enter
Sleep 100 ms
Type "duckdb https://www.tjak.dev/connections.duckdb"
Enter
Show

Type "SELECT * from connections_puzzle('2026-02-27');"
Enter

Sleep 5s

Type "SELECT * from guess_category_date('2026-02-27', ['JUDAS', 'DRILL', 'QUALITY', 'BUTTERFLY']);"
Enter

Sleep 5s

Type "SELECT * from guess_category_date('2026-02-27', ['IMPRESSION', 'AIR', 'QUALITY', 'MANNER']);"
Enter

Sleep 5s