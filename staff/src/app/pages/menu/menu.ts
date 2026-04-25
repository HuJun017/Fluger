import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { Categoria } from '../../models/categoria.model';
import { Prodotto } from '../../models/prodotto.model';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './menu.html',
  styleUrl: './menu.css'
})
export class MenuComponent implements OnInit {
  private api = inject(ApiService);

  categorie: Categoria[] = [];
  prodotti: Prodotto[] = [];
  categoriaSelezionata: Categoria | null = null;
  loading = true;
  errore: string | null = null;

  // Form per aggiungere una nuova categoria
  nuovaCategoria = '';

  // Form prodotto (usato sia per aggiunta che per modifica)
  formProdotto = this.prodottoVuoto();
  prodottoInModifica: Prodotto | null = null;
  mostraForm = false;

  ngOnInit(): void {
    this.caricaDati();
  }

  caricaDati(): void {
    this.loading = true;
    this.errore = null;
    this.api.getCategorie().subscribe({
      next: (cats) => {
        this.categorie = cats;
        // Seleziona la prima categoria di default
        if (cats.length > 0 && !this.categoriaSelezionata) {
          this.selezionaCategoria(cats[0]);
        } else if (this.categoriaSelezionata) {
          this.caricaProdotti();
        } else {
          this.loading = false;
        }
      },
      error: () => {
        this.errore = 'Impossibile caricare le categorie.';
        this.loading = false;
      },
    });
  }

  selezionaCategoria(cat: Categoria): void {
    this.categoriaSelezionata = cat;
    this.mostraForm = false;
    this.caricaProdotti();
  }

  caricaProdotti(): void {
    this.loading = true;
    // Carica tutti i prodotti e filtra per categoria lato client
    this.api.getProdotti().subscribe({
      next: (prods) => {
        this.prodotti = prods.filter(
          (p) => p.categoria_id === this.categoriaSelezionata?.id
        );
        this.loading = false;
      },
      error: () => {
        this.errore = 'Impossibile caricare i prodotti.';
        this.loading = false;
      },
    });
  }

  // ── Categorie ─────────────────────────────────────────────────────────────

  aggiungiCategoria(): void {
    const nome = this.nuovaCategoria.trim();
    if (!nome) return;
    this.api.addCategoria(nome).subscribe({
      next: () => {
        this.nuovaCategoria = '';
        this.caricaDati();
      },
      error: () => alert('Errore aggiunta categoria'),
    });
  }

  eliminaCategoria(cat: Categoria): void {
    if (!confirm(`Eliminare la categoria "${cat.nome}" e tutti i suoi prodotti?`)) return;
    this.api.deleteCategoria(cat.id).subscribe({
      next: () => {
        if (this.categoriaSelezionata?.id === cat.id) {
          this.categoriaSelezionata = null;
          this.prodotti = [];
        }
        this.caricaDati();
      },
      error: () => alert('Errore eliminazione categoria'),
    });
  }

  // ── Prodotti ──────────────────────────────────────────────────────────────

  apriFormNuovoProdotto(): void {
    this.prodottoInModifica = null;
    this.formProdotto = this.prodottoVuoto();
    this.mostraForm = true;
  }

  apriFormModifica(prodotto: Prodotto): void {
    this.prodottoInModifica = prodotto;
    // Copia i dati del prodotto nel form
    this.formProdotto = {
      nome: prodotto.nome,
      descrizione: prodotto.descrizione ?? '',
      prezzo: prodotto.prezzo,
      immagine_url: prodotto.immagine_url ?? '',
      disponibile: prodotto.disponibile,
      categoria_id: prodotto.categoria_id,
    };
    this.mostraForm = true;
  }

  salvaForm(): void {
    if (!this.formProdotto.nome || !this.categoriaSelezionata) return;

    // Normalizza i campi opzionali
    const payload = {
      ...this.formProdotto,
      descrizione: this.formProdotto.descrizione || null,
      immagine_url: this.formProdotto.immagine_url || null,
      categoria_id: this.categoriaSelezionata.id,
    };

    if (this.prodottoInModifica) {
      // Modifica prodotto esistente
      this.api.updateProdotto(this.prodottoInModifica.id, payload).subscribe({
        next: () => {
          this.mostraForm = false;
          this.caricaProdotti();
        },
        error: () => alert('Errore modifica prodotto'),
      });
    } else {
      // Aggiunta nuovo prodotto
      this.api.addProdotto(payload).subscribe({
        next: () => {
          this.mostraForm = false;
          this.caricaProdotti();
        },
        error: () => alert('Errore aggiunta prodotto'),
      });
    }
  }

  eliminaProdotto(prodotto: Prodotto): void {
    if (!confirm(`Eliminare "${prodotto.nome}"?`)) return;
    this.api.deleteProdotto(prodotto.id).subscribe({
      next: () => this.caricaProdotti(),
      error: () => alert('Errore eliminazione prodotto'),
    });
  }

  annullaForm(): void {
    this.mostraForm = false;
    this.prodottoInModifica = null;
  }

  private prodottoVuoto() {
    return {
      nome: '',
      descrizione: '',
      prezzo: 0,
      immagine_url: '',
      disponibile: true,
      categoria_id: this.categoriaSelezionata?.id ?? 0,
    };
  }
}
