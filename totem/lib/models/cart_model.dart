import 'package:flutter/foundation.dart';

// Rappresenta un singolo prodotto nel carrello con la sua quantità
class CartItem {
  final int prodottoId;
  final String nome;
  final double prezzo;
  int quantita;

  CartItem({
    required this.prodottoId,
    required this.nome,
    required this.prezzo,
    this.quantita = 1,
  });
}

// ChangeNotifier permette ai widget di ascoltare le modifiche al carrello
// e ricostruire la UI automaticamente tramite ListenableBuilder
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // Numero totale di prodotti (somma di tutte le quantità)
  int get count => _items.fold(0, (sum, item) => sum + item.quantita);

  double get totale =>
      _items.fold(0.0, (sum, item) => sum + item.prezzo * item.quantita);

  void addItem(int prodottoId, String nome, double prezzo) {
    final existing = _items.where((i) => i.prodottoId == prodottoId).firstOrNull;
    if (existing != null) {
      existing.quantita++;
    } else {
      _items.add(CartItem(prodottoId: prodottoId, nome: nome, prezzo: prezzo));
    }
    notifyListeners();
  }

  void decreaseItem(int prodottoId) {
    final existing = _items.where((i) => i.prodottoId == prodottoId).firstOrNull;
    if (existing == null) return;
    if (existing.quantita > 1) {
      existing.quantita--;
    } else {
      _items.remove(existing);
    }
    notifyListeners();
  }

  void removeItem(int prodottoId) {
    _items.removeWhere((i) => i.prodottoId == prodottoId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
