import { Component, OnInit, inject, signal, computed } from '@angular/core';
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

  ordini = signal<Ordine[]>([]);
  loading = signal(true);
  errore = signal<string | null>(null);
  mostraTutti = signal(false);

  readonly statiOrdine = STATI_ORDINE;

  readonly etichette: Record<string, string> = {
    ricevuto: 'Ricevuto',
    in_preparazione: 'In preparazione',
    pronto: 'Pronto',
    consegnato: 'Consegnato',
  };

  ordiniFiltrati = computed(() => {
    if (this.mostraTutti()) return this.ordini();
    return this.ordini().filter((o) => o.stato !== 'consegnato');
  });

  ngOnInit(): void {
    this.caricaOrdini();
  }

  caricaOrdini(): void {
    this.loading.set(true);
    this.errore.set(null);
    this.api.getOrdini().subscribe({
      next: (data) => {
        this.ordini.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.errore.set('Impossibile caricare gli ordini. Verifica che il backend sia attivo.');
        this.loading.set(false);
      },
    });
  }

  avanzaStato(ordine: Ordine): void {
    const idx = this.statiOrdine.indexOf(ordine.stato);
    if (idx >= this.statiOrdine.length - 1) return;
    const nuovoStato = this.statiOrdine[idx + 1];
    this.api.updateStatoOrdine(ordine.id, nuovoStato).subscribe({
      next: () => {
        this.ordini.update(list =>
          list.map(o => o.id === ordine.id ? { ...o, stato: nuovoStato } : o)
        );
      },
      error: () => alert('Errore aggiornamento stato'),
    });
  }

  totaleItems(ordine: Ordine): number {
    return ordine.items.reduce((sum, i) => sum + i.quantita, 0);
  }

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
