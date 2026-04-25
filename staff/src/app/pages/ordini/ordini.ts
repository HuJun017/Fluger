import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { Ordine, STATI_ORDINE } from '../../models/ordine.model';

@Component({
  selector: 'app-ordini',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './ordini.html',
  styleUrl: './ordini.css'
})
export class OrdiniComponent implements OnInit {
  private api = inject(ApiService);

  ordini: Ordine[] = [];
  loading = true;
  errore: string | null = null;

  // Mostra solo gli ordini non ancora consegnati per default
  mostraTutti = false;

  readonly statiOrdine = STATI_ORDINE;

  // Etichette leggibili per gli stati
  readonly etichette: Record<string, string> = {
    ricevuto: 'Ricevuto',
    in_preparazione: 'In preparazione',
    pronto: 'Pronto',
    consegnato: 'Consegnato',
  };

  ngOnInit(): void {
    this.caricaOrdini();
  }

  caricaOrdini(): void {
    this.loading = true;
    this.errore = null;
    this.api.getOrdini().subscribe({
      next: (data) => {
        this.ordini = data;
        this.loading = false;
      },
      error: () => {
        this.errore = 'Impossibile caricare gli ordini. Verifica che il backend sia attivo.';
        this.loading = false;
      },
    });
  }

  get ordiniFiltrati(): Ordine[] {
    if (this.mostraTutti) return this.ordini;
    return this.ordini.filter((o) => o.stato !== 'consegnato');
  }

  // Avanza l'ordine allo stato successivo nella sequenza
  avanzaStato(ordine: Ordine): void {
    const idx = this.statiOrdine.indexOf(ordine.stato);
    if (idx >= this.statiOrdine.length - 1) return; // già all'ultimo stato
    const nuovoStato = this.statiOrdine[idx + 1];
    this.api.updateStatoOrdine(ordine.id, nuovoStato).subscribe({
      next: () => (ordine.stato = nuovoStato),
      error: () => alert('Errore aggiornamento stato'),
    });
  }

  // Calcola il totale delle quantità in un ordine
  totaleItems(ordine: Ordine): number {
    return ordine.items.reduce((sum, i) => sum + i.quantita, 0);
  }

  // Classe CSS in base allo stato per colorare i badge
  classeStato(stato: string): string {
    const mappa: Record<string, string> = {
      ricevuto: 'badge-ricevuto',
      in_preparazione: 'badge-preparazione',
      pronto: 'badge-pronto',
      consegnato: 'badge-consegnato',
    };
    return mappa[stato] ?? '';
  }
}
