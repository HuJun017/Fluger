class Prodotto {
  final int id;
  final String nome;
  final String? descrizione;
  final double prezzo;
  final String? immagineUrl;
  final int categoriaId;
  final String categoriaNome;

  const Prodotto({
    required this.id,
    required this.nome,
    this.descrizione,
    required this.prezzo,
    this.immagineUrl,
    required this.categoriaId,
    required this.categoriaNome,
  });

  factory Prodotto.fromJson(Map<String, dynamic> json) => Prodotto(
        id: json['id'] as int,
        nome: json['nome'] as String,
        descrizione: json['descrizione'] as String?,
        prezzo: (json['prezzo'] as num).toDouble(),
        immagineUrl: json['immagine_url'] as String?,
        categoriaId: json['categoria_id'] as int,
        categoriaNome: json['categoria_nome'] as String? ?? '',
      );
}
