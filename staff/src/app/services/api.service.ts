import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Categoria } from '../models/categoria.model';
import { Prodotto } from '../models/prodotto.model';
import { Ordine } from '../models/ordine.model';

// Cambia con l'URL del tuo backend Flask (es. URL del port forwarding in Codespaces)
const BASE = 'https://studious-succotash-v6pxgvxpxx6x3jgg-5000.app.github.dev/api';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private http = inject(HttpClient);

  // ── Categorie ─────────────────────────────────────────────────────────────

  getCategorie(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>(`${BASE}/categorie`);
  }

  addCategoria(nome: string): Observable<Categoria> {
    return this.http.post<Categoria>(`${BASE}/categorie`, { nome });
  }

  deleteCategoria(id: number): Observable<unknown> {
    return this.http.delete(`${BASE}/categorie/${id}`);
  }

  // ── Prodotti ──────────────────────────────────────────────────────────────

  getProdotti(): Observable<Prodotto[]> {
    return this.http.get<Prodotto[]>(`${BASE}/prodotti`);
  }

  addProdotto(data: Omit<Prodotto, 'id' | 'categoria_nome'>): Observable<{ id: number }> {
    return this.http.post<{ id: number }>(`${BASE}/prodotti`, data);
  }

  updateProdotto(id: number, data: Omit<Prodotto, 'id' | 'categoria_nome'>): Observable<unknown> {
    return this.http.put(`${BASE}/prodotti/${id}`, data);
  }

  deleteProdotto(id: number): Observable<unknown> {
    return this.http.delete(`${BASE}/prodotti/${id}`);
  }

  // ── Ordini ────────────────────────────────────────────────────────────────

  getOrdini(): Observable<Ordine[]> {
    return this.http.get<Ordine[]>(`${BASE}/ordini`);
  }

  updateStatoOrdine(id: number, stato: string): Observable<unknown> {
    return this.http.put(`${BASE}/ordini/${id}/stato`, { stato });
  }
}
