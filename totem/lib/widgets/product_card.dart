import 'package:flutter/material.dart';
import '../models/prodotto.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';

class ProductCard extends StatelessWidget {
  final Prodotto prodotto;
  final CartModel cart;

  const ProductCard({super.key, required this.prodotto, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immagine del prodotto
          Expanded(
            child: prodotto.immagineUrl != null
                ? Image.network(
                    ApiService.imageProxyUrl(prodotto.immagineUrl!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Nome, descrizione, prezzo e controlli quantità
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prodotto.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (prodotto.descrizione != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    prodotto.descrizione!,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '€${prodotto.prezzo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    // ListenableBuilder si ricostruisce ogni volta che il carrello cambia
                    ListenableBuilder(
                      listenable: cart,
                      builder: (context, _) {
                        final quantita = cart.items
                            .where((i) => i.prodottoId == prodotto.id)
                            .fold(0, (sum, i) => sum + i.quantita);

                        if (quantita == 0) {
                          return GestureDetector(
                            onTap: () => cart.addItem(
                                prodotto.id, prodotto.nome, prodotto.prezzo),
                            child: const Icon(Icons.add_circle,
                                color: Colors.orange, size: 22),
                          );
                        }

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => cart.decreaseItem(prodotto.id),
                              child: const Icon(Icons.remove_circle_outline,
                                  color: Colors.orange, size: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text('$quantita',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            GestureDetector(
                              onTap: () => cart.addItem(
                                  prodotto.id, prodotto.nome, prodotto.prezzo),
                              child: const Icon(Icons.add_circle,
                                  color: Colors.orange, size: 20),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
        ),
      );
}
