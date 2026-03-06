CREATE OR REPLACE MACRO
    connections_data(ymd) AS TABLE
        SELECT * from read_json(printf('https://www.nytimes.com/svc/connections/v2/%s.json', ymd));

CREATE OR REPLACE MACRO
    connections_categories(ymd) AS TABLE
        SELECT unnest(categories, recursive := true), ['🟨', '🟩', '🟦', '🟪'][generate_subscripts(categories, 1)] AS emoji from connections_data(ymd);

CREATE OR REPLACE MACRO
    connections_words(ymd) AS TABLE
        WITH cards AS (SELECT unnest(cards, recursive := true) from connections_categories(ymd))
        SELECT content AS word, position from cards order by position asc;

CREATE OR REPLACE MACRO
    connections_puzzle(ymd) AS TABLE
        WITH grid AS (SELECT word, position AS idx from connections_words(ymd))
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
        connections_ymd(now());

CREATE OR REPLACE VIEW todays_categories AS
    SELECT * FROM connections_categories(connections_ymd_today());

CREATE OR REPLACE VIEW todays_words AS
    SELECT * from connections_words(connections_ymd_today());

CREATE OR REPLACE VIEW todays_puzzle AS
    SELECT * from connections_puzzle(connections_ymd_today());

CREATE OR REPLACE MACRO
    guess_category_date(ymd, words_guess) AS TABLE
        WITH guess AS (
            SELECT unnest(words_guess) as word, generate_subscripts(words_guess, 1) AS guess_idx
        ), cat_words AS (
            SELECT title AS category, emoji, unnest(cards).content AS word FROM connections_categories(ymd)
        ), result AS (
            SELECT guess.word, emoji, category FROM guess INNER JOIN cat_words ON cat_words.word = guess.word ORDER BY guess_idx ASC
        ), display AS (
            SELECT coalesce(string_agg(result.emoji, ''), '') AS emoji FROM result
        ), cats AS (
            SELECT count(DISTINCT result.category) AS num_categories, any_value(result.category) AS category FROM result
        )
        SELECT
            CASE
                WHEN len(list_distinct(words_guess)) != 4 THEN 'invalid_not_four_words'
                WHEN length_grapheme(display.emoji) != 4 THEN 'invalid_not_in_word_list'
                WHEN cats.num_categories != 1 THEN 'incorrect'
                ELSE 'correct'
            END AS status,
            CASE
                WHEN len(list_distinct(words_guess)) != 4 THEN NULL
                ELSE display.emoji
            END AS emoji,
            CASE
                WHEN cats.num_categories = 1 AND len(list_distinct(words_guess)) = 4 AND length_grapheme(display.emoji) = 4 THEN cats.category
                ELSE NULL
            END AS category
        FROM display, cats;

CREATE OR REPLACE MACRO
    guess_category_today(words_guess) AS TABLE
        SELECT * from guess_category_date(connections_ymd_today(), words_guess);