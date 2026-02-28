CREATE OR REPLACE MACRO
    connections_data(ymd) AS TABLE
        SELECT * from read_json(printf('https://www.nytimes.com/svc/connections/v2/%s.json', ymd));

CREATE OR REPLACE MACRO
    connections_categories(ymd) AS TABLE
        SELECT unnest(categories, recursive := true) from connections_data(ymd);

CREATE OR REPLACE MACRO
    connections_words(ymd) AS TABLE
        WITH cards as (SELECT unnest(cards, recursive := true) from connections_categories(ymd))
        SELECT content as word, position from cards order by position asc;

CREATE OR REPLACE MACRO
    connections_puzzle(ymd) AS TABLE
        WITH grid as (SELECT word, position as idx from connections_words(ymd))
        SELECT
            max(word) FILTER (WHERE idx % 4 = 0) AS word1,
            max(word) FILTER (WHERE idx % 4 = 1) AS word2,
            max(word) FILTER (WHERE idx % 4 = 2) AS word3,
            max(word) FILTER (WHERE idx % 4 = 3) AS word4
        FROM grid
        GROUP BY idx // 4
        ORDER BY idx // 4;

CREATE OR REPLACE MACRO
    connections_ymd(ts) AS
        strftime(ts AT TIME ZONE 'America/New_York', '%Y-%m-%d');

CREATE OR REPLACE MACRO
    connections_ymd_today() AS
        connections_ymd(current_localtimestamp());


CREATE VIEW todays_categories AS
    SELECT * FROM connections_categories(connections_ymd_today());

CREATE VIEW todays_words AS
    SELECT * from connections_words(connections_ymd_today());

CREATE VIEW todays_puzzle AS
    SELECT * from connections_puzzle(connections_ymd_today());
