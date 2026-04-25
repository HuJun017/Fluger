class Categoria {
  final int id;
  final String nome;
  final int ordine;

  const Categoria({required this.id, required this.nome, required this.ordine});

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json['id'] as int,
        nome: json['nome'] as String,
        ordine: json['ordine'] as int? ?? 0,
      );
}
