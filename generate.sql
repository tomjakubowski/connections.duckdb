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
            SELECT unnest(words_guess) AS word
        ), cat_words AS (
            SELECT title AS category, emoji, unnest(cards).content AS word FROM connections_categories(ymd)
        ), result AS (
        ), display AS (
            SELECT coalesce(string_agg(cat_words.emoji, ''), '') AS emoji from guess INNER JOIN cat_words ON cat_words.word = guess.word
        )
        -- invalid: user must guess 4 distinct words
        SELECT * FROM VALUES ('invalid_not_four_words', NULL, NULL) AS t(status, emoji, category) WHERE len(list_distinct(words_guess)) != 4
        UNION ALL
        -- invalid: user's guesses must all be in the word list
        SELECT
            'invalid_not_in_word_list' AS status, NULL::varchar AS emoji, NULL::varchar AS category
            FROM result
            WHERE len(list_distinct(words_guess)) == 4 AND length_grapheme(display.emoji) != 4
        UNION ALL
        -- incorrect: guesses were not all in same category
        SELECT
            'incorrect' AS status, result.emoji, NULL::varchar AS category
            FROM result
            WHERE len(list_distinct(words_guess)) == 4 AND length_grapheme(display.emoji) == 4;

        -- SELECT "invalid" AS status, NULL AS emoji, NULL AS category WHERE len(words_guess) != 4;kku
            -- WITH result AS (
            --     SELECT title, list_sort(list_transform(cards, x -> x.content)) AS sorted_words
            --     FROM connections_categories(ymd) WHERE
            --     sorted_words = list_sort(words_guess)
            -- ) SELECT title FROM result

CREATE OR REPLACE MACRO
    guess_category_today(words_guess) AS TABLE
        SELECT * from guess_category_date(connections_ymd_today(), words_guess);