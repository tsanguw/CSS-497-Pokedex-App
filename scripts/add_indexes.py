"""Adds the query indexes to the bundled SQLite database in place.

SQLite already indexes every primary key and UNIQUE column, so most of the
app's lookups are fast. The one real gap is "which Pokemon learn this move"
(Move detail screen): MOVESET's primary key leads with pok_id, so searching by
move_id scanned all 330,525 rows (~18 ms on a desktop, far worse on a phone).
idx_moveset_move cuts that to ~0.4 ms for +4.5 MB.

Measured and rejected (each gained ~0.1 ms on tables of 120-2,900 rows):
POKEMON_POSSESSES_ABILITY(abi_id), EVOLUTION(pre/evol_pok_id),
TYPE_EFFICACY(target_type_id).

Run from the repo root:  python scripts/add_indexes.py
Re-running is safe (CREATE INDEX IF NOT EXISTS). Remember to bump
_assetDbVersion in pokedex_app/lib/database_helper.dart so installed apps
pick up the new file.
"""
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent.parent / "pokedex_app" / "assets" / "pokedex.db"

INDEXES = [
    "CREATE INDEX IF NOT EXISTS idx_moveset_move ON MOVESET (move_id, pok_id)",
]


def main() -> None:
    con = sqlite3.connect(DB_PATH)
    for ddl in INDEXES:
        con.execute(ddl)
    con.commit()
    plan = con.execute(
        "EXPLAIN QUERY PLAN SELECT pok_id FROM MOVESET WHERE move_id = 71").fetchall()
    print("plan for a move lookup:", plan[0][3])
    print("integrity:", con.execute("PRAGMA integrity_check").fetchone()[0])
    con.execute("VACUUM")
    con.close()
    print(f"{DB_PATH.name}: {DB_PATH.stat().st_size / 1e6:.2f} MB")


if __name__ == "__main__":
    main()
