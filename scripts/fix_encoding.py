"""One-off cleanup for text that was corrupted to U+FFFD by a stdout encoding
bug in pokedex.py (now fixed there). Repairs the committed insert scripts and
the bundled SQLite database in place.

Run from the repo root:  python scripts/fix_encoding.py
Re-running is safe: once nothing contains U+FFFD it changes nothing.
"""
import codecs
import re
import sqlite3
from pathlib import Path

BAD = "�"
ROOT = Path(__file__).resolve().parent.parent
SQL_FILES = [
    ROOT / "complete-db-inserts" / "abilities-inserts.sql",
    ROOT / "complete-db-inserts" / "item-inserts.sql",
    ROOT / "complete-db-inserts" / "move-inserts.sql",
]
DB_PATH = ROOT / "pokedex_app" / "assets" / "pokedex.db"

# Literal words first, then the context rules.
WORDS = [
    ("POK" + BAD, "POKÉ"),
    ("Pok" + BAD, "Poké"),
    ("pok" + BAD, "poké"),
    ("Caf" + BAD, "Café"),
    ("jalape" + BAD + "o", "jalapeño"),
    ("flab" + BAD + "b" + BAD, "flabébé"),
    ("Pa" + BAD + "u", "Pa'u"),
]
MULTIPLIER = re.compile(r"(?<=\d)" + BAD)                  # 1.5� -> 1.5×
APOSTROPHE = re.compile(r"(?<=[A-Za-z])" + BAD + r"(?=s\b)")  # it�s -> it's


def fix(text: str) -> str:
    for old, new in WORDS:
        text = text.replace(old, new)
    text = MULTIPLIER.sub("×", text)
    return APOSTROPHE.sub("'", text)


def _cp1252_fallback(err: UnicodeDecodeError):
    # Valid UTF-8 sequences decode normally; a stray byte is Windows-1252.
    return err.object[err.start:err.end].decode("cp1252", errors="replace"), err.end


codecs.register_error("cp1252_fallback", _cp1252_fallback)


def fix_files() -> None:
    for path in SQL_FILES:
        raw = path.read_bytes()
        # Some insert scripts mix UTF-8 rows with raw Windows-1252 bytes.
        original = raw.decode("utf-8", errors="cp1252_fallback")
        fixed = fix(original)
        # Write bytes, not text, so the file's existing line endings survive.
        data = fixed.encode("utf-8")
        if data != raw:
            path.write_bytes(data)
        print(f"{path.name}: {original.count(BAD)} -> {fixed.count(BAD)} "
              f"bad characters")


def fix_db() -> None:
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    tables = [r[0] for r in cur.execute(
        "select name from sqlite_master where type='table'")]
    changed = 0
    for table in tables:
        cols = [r[1] for r in cur.execute(f"pragma table_info({table})")]
        pk = "rowid"
        for col in cols:
            rows = cur.execute(
                f"select {pk}, {col} from {table} where {col} like ?",
                (f"%{BAD}%",)).fetchall()
            for rowid, value in rows:
                if isinstance(value, str):
                    cur.execute(f"update {table} set {col}=? where {pk}=?",
                                (fix(value), rowid))
                    changed += 1
    con.commit()
    left = sum(
        cur.execute(f"select count(*) from {t} where "
                    + " or ".join(f"{c} like '%{BAD}%'" for c in
                                  [r[1] for r in cur.execute(f"pragma table_info({t})")])
                    ).fetchone()[0]
        for t in tables)
    cur.execute("vacuum")
    con.close()
    print(f"pokedex.db: {changed} values fixed, {left} rows still contain bad characters")


if __name__ == "__main__":
    fix_files()
    fix_db()
