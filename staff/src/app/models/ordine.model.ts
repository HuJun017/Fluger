export interface OrdineItem {
  prodotto_id: number;
  nome: string;
  quantita: number;
  prezzo_unitario: number;
}

export interface Ordine {
  id: number;
  numero: number;
  stato: 'ricevuto' | 'in_preparazione' | 'pronto' | 'consegnato';
  totale: number;
  created_at: string;
  items: OrdineItem[];
}

export const STATI_ORDINE = ['ricevuto', 'in_preparazione', 'pronto', 'consegnato'] as const;
