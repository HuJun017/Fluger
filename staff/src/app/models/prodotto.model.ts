export interface Prodotto {
  id: number;
  nome: string;
  descrizione: string | null;
  prezzo: number;
  immagine_url: string | null;
  disponibile: boolean;
  categoria_id: number;
  categoria_nome: string;
}
