import pytest
import duckdb
from typing import Any, Callable

TESTPUZ_YMD = "2025-03-04"

TESTPUZ_VARS = {"ymd": TESTPUZ_YMD}

TESTPUZ_WORD_LIST = [
    "FRESH",
    "DAISY",
    "BUCKET",
    "MOP",
    "SCROOGE",
    "FOOD",
    "TWIST",
    "DEWY",
    "TANGLE",
    "MOUNTAIN",
    "THATCH",
    "PIP",
    "SMOOTH",
    "SUPPLY",
    "GLOWING",
    "MAT",
]


@pytest.fixture
def conn():
    return duckdb.connect("connections.duckdb", read_only=True)


Execute = Callable[[str, dict[str, Any]], dict[str, Any]]


@pytest.fixture
def execute(conn: duckdb.DuckDBPyConnection):
    def inner(query: str, vars: dict[str, Any]):
        # low-effort way to get result as a dict of columns
        return conn.execute(query, vars).pl().to_dict(as_series=False)

    return inner


def test_words(
    execute: Execute,
):
    words = execute(
        "SELECT * FROM connections_words($ymd)",
        TESTPUZ_VARS,
    )
    assert words["word"] == TESTPUZ_WORD_LIST
    assert words["position"] == sorted(range(16))


def test_puzzle(execute: Execute):
    puz = execute(
        "SELECT * FROM connections_puzzle($ymd)",
        TESTPUZ_VARS,
    )
    assert puz["word1"] == TESTPUZ_WORD_LIST[0::4]
    assert puz["word2"] == TESTPUZ_WORD_LIST[1::4]
    assert puz["word3"] == TESTPUZ_WORD_LIST[2::4]
    assert puz["word4"] == TESTPUZ_WORD_LIST[3::4]


def test_guess_invalid_not_four_words(execute: Execute):
    # various ways to mis-specify four words:
    # - three words
    # - five words
    # - four non-distinct words
    for guess in [list("ABC"), list("ABCDE"), list("ABCA")]:
        result = execute(
            "SELECT * FROM guess_category_date($ymd, $guess)",
            {**TESTPUZ_VARS, "guess": guess},
        )
        assert result["status"] == ["invalid_not_four_words"]


def test_guess_invalid_not_in_word_list(execute: Execute):
    for guess in [
        list("ABCD"),  # four words not in the word list
        TESTPUZ_WORD_LIST[0:3] + ["c412hqucHKw"],  # one word not in the word list
    ]:
        result = execute(
            "SELECT * FROM guess_category_date($ymd, $guess)",
            {**TESTPUZ_VARS, "guess": guess},
        )
        assert result["status"] == ["invalid_not_in_word_list"]


def test_guess_incorrect(execute: Execute):
    guess = ["DEWY", "MOP", "BUCKET", "DAISY"]  # ____ HEAD
    result = execute(
        "SELECT * FROM guess_category_date($ymd, $guess)",
        {**TESTPUZ_VARS, "guess": guess},
    )
    assert result["status"] == ["incorrect"]
    assert result["emoji"] == ["🟨🟩🟦🟪"]


def test_guess_correct(execute: Execute):
    guess1 = ["MOP", "THATCH", "MAT", "TANGLE"]
    guess2 = sorted(guess1)  # try in another order too
    assert guess1 != guess2
    for guess in [guess1, guess2]:
        result = execute(
            "SELECT * FROM guess_category_date($ymd, $guess)",
            {**TESTPUZ_VARS, "guess": guess},
        )
        assert result["status"] == ["correct"]
        assert result["emoji"] == ["🟩🟩🟩🟩"]
        assert result["category"] == ["MESS OF HAIR"]
