import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';

// Schermata carrello: mostra i prodotti aggiunti, il totale e il tasto di invio
class CartPage extends StatefulWidget {
  final CartModel cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _loading = false;

  Future<void> _inviaOrdine() async {
    if (widget.cart.items.isEmpty) return;

    setState(() => _loading = true);
    try {
      // Costruisce la lista items nel formato atteso dal backend
      final items = widget.cart.items
          .map((i) => {'prodotto_id': i.prodottoId, 'quantita': i.quantita})
          .toList();

      final result = await ApiService.createOrdine(items);
      final numero = result['numero'] as int;

      // Naviga alla pagina di conferma passando il numero ordine nella rotta
      if (mounted) context.go('/confirm/$numero');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Il tuo ordine'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          final items = widget.cart.items;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Carrello vuoto',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Aggiungi qualcosa dal menu!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Lista dei prodotti nel carrello
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          // Nome e prezzo unitario
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.nome,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text(
                                  '€${item.prezzo.toStringAsFixed(2)} cad.',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Controlli quantità
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.orange),
                                onPressed: () =>
                                    widget.cart.decreaseItem(item.prodottoId),
                              ),
                              Text('${item.quantita}',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.orange),
                                onPressed: () => widget.cart.addItem(
                                    item.prodottoId, item.nome, item.prezzo),
                              ),
                            ],
                          ),
                          // Subtotale e tasto elimina
                          SizedBox(
                            width: 64,
                            child: Text(
                              '€${(item.prezzo * item.quantita).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                widget.cart.removeItem(item.prodottoId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Barra inferiore con totale e tasto invio
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Totale',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          '€${widget.cart.totale.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _loading ? null : _inviaOrdine,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Invia ordine',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
