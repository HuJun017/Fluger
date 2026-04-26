import json
import requests as http
from datetime import datetime, date
from decimal import Decimal
from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from databasewrapper import DatabaseWrapper

app = Flask(__name__)
CORS(app)


def serialize(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError(f"Tipo non serializzabile: {type(obj)}")


def ok(data, code=200):
    return app.response_class(
        json.dumps(data, default=serialize),
        status=code,
        mimetype="application/json"
    )


def err(msg, code=400):
    return jsonify({"error": msg}), code


# ── PROXY IMMAGINI ───────────────────────────────────────────────────────────

@app.route("/api/immagine")
def proxy_immagine():
    url = request.args.get("url")
    if not url:
        return err("Parametro 'url' obbligatorio")
    try:
        from urllib.parse import urlparse
        origin = f"{urlparse(url).scheme}://{urlparse(url).netloc}"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
            "Accept": "image/webp,image/apng,image/*,*/*;q=0.8",
            "Referer": origin + "/",
        }
        r = http.get(url, timeout=8, headers=headers, allow_redirects=True)
        if r.status_code != 200:
            return err(f"Sorgente ha risposto {r.status_code}", 502)
        return Response(r.content, content_type=r.headers.get("Content-Type", "image/jpeg"))
    except Exception as e:
        return err(f"Impossibile scaricare l'immagine: {e}", 502)


# ── CATEGORIE ────────────────────────────────────────────────────────────────

@app.route("/api/categorie", methods=["GET"])
def get_categorie():
    db = DatabaseWrapper()
    try:
        return ok(db.get_categorie())
    finally:
        db.close()


@app.route("/api/categorie", methods=["POST"])
def add_categoria():
    body = request.get_json()
    if not body or not body.get("nome"):
        return err("Campo 'nome' obbligatorio")
    db = DatabaseWrapper()
    try:
        new_id = db.add_categoria(body["nome"])
        return ok({"id": new_id, "nome": body["nome"]}, 201)
    finally:
        db.close()


@app.route("/api/categorie/<int:categoria_id>", methods=["DELETE"])
def delete_categoria(categoria_id):
    db = DatabaseWrapper()
    try:
        db.delete_categoria(categoria_id)
        return ok({"deleted": categoria_id})
    finally:
        db.close()


# ── PRODOTTI ─────────────────────────────────────────────────────────────────

@app.route("/api/prodotti", methods=["GET"])
def get_prodotti():
    db = DatabaseWrapper()
    try:
        return ok(db.get_prodotti())
    finally:
        db.close()


@app.route("/api/prodotti/<int:prodotto_id>", methods=["GET"])
def get_prodotto(prodotto_id):
    db = DatabaseWrapper()
    try:
        prodotto = db.get_prodotto(prodotto_id)
        if not prodotto:
            return err("Prodotto non trovato", 404)
        return ok(prodotto)
    finally:
        db.close()


@app.route("/api/categorie/<int:categoria_id>/prodotti", methods=["GET"])
def get_prodotti_by_categoria(categoria_id):
    db = DatabaseWrapper()
    try:
        return ok(db.get_prodotti_by_categoria(categoria_id))
    finally:
        db.close()


@app.route("/api/prodotti", methods=["POST"])
def add_prodotto():
    body = request.get_json()
    required = ["nome", "prezzo", "categoria_id"]
    if not body or any(k not in body for k in required):
        return err(f"Campi obbligatori: {required}")
    db = DatabaseWrapper()
    try:
        new_id = db.add_prodotto(
            body["nome"],
            body.get("descrizione"),
            body["prezzo"],
            body.get("immagine_url"),
            body["categoria_id"]
        )
        return ok({"id": new_id}, 201)
    finally:
        db.close()


@app.route("/api/prodotti/<int:prodotto_id>", methods=["PUT"])
def update_prodotto(prodotto_id):
    body = request.get_json()
    required = ["nome", "prezzo", "categoria_id", "disponibile"]
    if not body or any(k not in body for k in required):
        return err(f"Campi obbligatori: {required}")
    db = DatabaseWrapper()
    try:
        db.update_prodotto(
            prodotto_id,
            body["nome"],
            body.get("descrizione"),
            body["prezzo"],
            body.get("immagine_url"),
            body["disponibile"],
            body["categoria_id"]
        )
        return ok({"updated": prodotto_id})
    finally:
        db.close()


@app.route("/api/prodotti/<int:prodotto_id>", methods=["DELETE"])
def delete_prodotto(prodotto_id):
    db = DatabaseWrapper()
    try:
        db.delete_prodotto(prodotto_id)
        return ok({"deleted": prodotto_id})
    finally:
        db.close()


# ── ORDINI ───────────────────────────────────────────────────────────────────

@app.route("/api/ordini", methods=["GET"])
def get_ordini():
    db = DatabaseWrapper()
    try:
        return ok(db.get_ordini())
    finally:
        db.close()


@app.route("/api/ordini/<int:ordine_id>", methods=["GET"])
def get_ordine(ordine_id):
    db = DatabaseWrapper()
    try:
        righe = db.get_ordine(ordine_id)
        if not righe:
            return err("Ordine non trovato", 404)
        return ok(righe)
    finally:
        db.close()


@app.route("/api/ordini", methods=["POST"])
def create_ordine():
    body = request.get_json()
    # body atteso: { "items": [{ "prodotto_id": 1, "quantita": 2 }, ...] }
    if not body or not body.get("items"):
        return err("Campo 'items' obbligatorio")
    db = DatabaseWrapper()
    try:
        result = db.create_ordine(body["items"])
        return ok(result, 201)
    except ValueError as e:
        return err(str(e), 404)
    finally:
        db.close()


@app.route("/api/ordini/<int:ordine_id>/stato", methods=["PUT"])
def update_stato_ordine(ordine_id):
    body = request.get_json()
    if not body or not body.get("stato"):
        return err("Campo 'stato' obbligatorio")
    db = DatabaseWrapper()
    try:
        db.update_stato_ordine(ordine_id, body["stato"])
        return ok({"id": ordine_id, "stato": body["stato"]})
    except ValueError as e:
        return err(str(e))
    finally:
        db.close()


# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app.run(debug=True, port=5000)
