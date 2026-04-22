import json
import pymysql
import pymysql.cursors
import os
from dotenv import load_dotenv

load_dotenv()


class DatabaseWrapper:
    def __init__(self):
        self.conn = pymysql.connect(
            host=os.getenv("MYSQL_HOST"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASENAME"),
            port=int(os.getenv("MYSQL_PORT")),
            ssl_disabled=False,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False
        )

    def _cursor(self):
        self.conn.ping(reconnect=True)
        return self.conn.cursor()

    # ── CATEGORIE ────────────────────────────────────────────────────────────

    def get_categorie(self):
        with self._cursor() as cur:
            cur.execute("SELECT * FROM categoria ORDER BY ordine, nome")
            return cur.fetchall()

    def add_categoria(self, nome):
        with self._cursor() as cur:
            cur.execute("INSERT INTO categoria (nome) VALUES (%s)", (nome,))
            self.conn.commit()
            return cur.lastrowid

    def delete_categoria(self, categoria_id):
        with self._cursor() as cur:
            cur.execute("DELETE FROM categoria WHERE id = %s", (categoria_id,))
            self.conn.commit()

    # ── PRODOTTI ─────────────────────────────────────────────────────────────

    def get_prodotti(self):
        with self._cursor() as cur:
            cur.execute("""
                SELECT p.*, c.nome AS categoria_nome
                FROM prodotto p
                JOIN categoria c ON p.categoria_id = c.id
                ORDER BY c.ordine, c.nome, p.nome
            """)
            return cur.fetchall()

    def get_prodotti_by_categoria(self, categoria_id):
        with self._cursor() as cur:
            cur.execute("""
                SELECT p.*, c.nome AS categoria_nome
                FROM prodotto p
                JOIN categoria c ON p.categoria_id = c.id
                WHERE p.categoria_id = %s AND p.disponibile = 1
                ORDER BY p.nome
            """, (categoria_id,))
            return cur.fetchall()

    def get_prodotto(self, prodotto_id):
        with self._cursor() as cur:
            cur.execute("""
                SELECT p.*, c.nome AS categoria_nome
                FROM prodotto p
                JOIN categoria c ON p.categoria_id = c.id
                WHERE p.id = %s
            """, (prodotto_id,))
            return cur.fetchone()

    def add_prodotto(self, nome, descrizione, prezzo, immagine_url, categoria_id):
        with self._cursor() as cur:
            cur.execute("""
                INSERT INTO prodotto (nome, descrizione, prezzo, immagine_url, categoria_id)
                VALUES (%s, %s, %s, %s, %s)
            """, (nome, descrizione, prezzo, immagine_url, categoria_id))
            self.conn.commit()
            return cur.lastrowid

    def update_prodotto(self, prodotto_id, nome, descrizione, prezzo, immagine_url, disponibile, categoria_id):
        with self._cursor() as cur:
            cur.execute("""
                UPDATE prodotto
                SET nome=%s, descrizione=%s, prezzo=%s,
                    immagine_url=%s, disponibile=%s, categoria_id=%s
                WHERE id = %s
            """, (nome, descrizione, prezzo, immagine_url, disponibile, categoria_id, prodotto_id))
            self.conn.commit()

    def delete_prodotto(self, prodotto_id):
        with self._cursor() as cur:
            cur.execute("DELETE FROM prodotto WHERE id = %s", (prodotto_id,))
            self.conn.commit()

    # ── ORDINI ───────────────────────────────────────────────────────────────

    def get_ordini(self):
        with self._cursor() as cur:
            cur.execute("""
                SELECT o.*,
                       JSON_ARRAYAGG(
                           JSON_OBJECT(
                               'prodotto_id', oi.prodotto_id,
                               'nome', p.nome,
                               'quantita', oi.quantita,
                               'prezzo_unitario', oi.prezzo_unitario
                           )
                       ) AS items
                FROM ordine o
                JOIN ordine_item oi ON o.id = oi.ordine_id
                JOIN prodotto p ON oi.prodotto_id = p.id
                GROUP BY o.id
                ORDER BY o.created_at DESC
            """)
            rows = cur.fetchall()
            # JSON_ARRAYAGG restituisce una stringa — la parsiamo in lista Python
            for row in rows:
                if isinstance(row["items"], str):
                    row["items"] = json.loads(row["items"])
            return rows

    def get_ordine(self, ordine_id):
        with self._cursor() as cur:
            cur.execute("""
                SELECT o.id, o.numero, o.stato, o.totale, o.created_at,
                       oi.prodotto_id, p.nome AS prodotto_nome,
                       oi.quantita, oi.prezzo_unitario
                FROM ordine o
                JOIN ordine_item oi ON o.id = oi.ordine_id
                JOIN prodotto p ON oi.prodotto_id = p.id
                WHERE o.id = %s
            """, (ordine_id,))
            rows = cur.fetchall()
            if not rows:
                return None
            # Struttura: un oggetto ordine con lista items dentro
            ordine = {
                "id": rows[0]["id"],
                "numero": rows[0]["numero"],
                "stato": rows[0]["stato"],
                "totale": rows[0]["totale"],
                "created_at": rows[0]["created_at"],
                "items": [
                    {
                        "prodotto_id": r["prodotto_id"],
                        "prodotto_nome": r["prodotto_nome"],
                        "quantita": r["quantita"],
                        "prezzo_unitario": r["prezzo_unitario"],
                    }
                    for r in rows
                ]
            }
            return ordine

    def create_ordine(self, items):
        # items: lista di dict {prodotto_id, quantita}
        with self._cursor() as cur:
            # calcola il prossimo numero ordine e il totale
            cur.execute("SELECT COALESCE(MAX(numero), 0) + 1 FROM ordine")
            numero = cur.fetchone()["COALESCE(MAX(numero), 0) + 1"]

            totale = 0
            items_con_prezzo = []
            for item in items:
                cur.execute("SELECT prezzo FROM prodotto WHERE id = %s", (item["prodotto_id"],))
                row = cur.fetchone()
                if not row:
                    raise ValueError(f"Prodotto {item['prodotto_id']} non trovato")
                prezzo = float(row["prezzo"])
                totale += prezzo * item["quantita"]
                items_con_prezzo.append({**item, "prezzo_unitario": prezzo})

            cur.execute(
                "INSERT INTO ordine (numero, totale) VALUES (%s, %s)",
                (numero, round(totale, 2))
            )
            ordine_id = cur.lastrowid

            for item in items_con_prezzo:
                cur.execute("""
                    INSERT INTO ordine_item (ordine_id, prodotto_id, quantita, prezzo_unitario)
                    VALUES (%s, %s, %s, %s)
                """, (ordine_id, item["prodotto_id"], item["quantita"], item["prezzo_unitario"]))

            self.conn.commit()
            return {"id": ordine_id, "numero": numero, "totale": round(totale, 2)}

    def update_stato_ordine(self, ordine_id, stato):
        stati_validi = {"ricevuto", "in_preparazione", "pronto", "consegnato"}
        if stato not in stati_validi:
            raise ValueError(f"Stato non valido: {stato}")
        with self._cursor() as cur:
            cur.execute("UPDATE ordine SET stato = %s WHERE id = %s", (stato, ordine_id))
            self.conn.commit()

    def close(self):
        self.conn.close()
