import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_model.dart';

// Schermata mostrata dopo che l'ordine è stato inviato con successo
class ConfirmPage extends StatelessWidget {
  final int numero;
  final CartModel cart;

  const ConfirmPage({super.key, required this.numero, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Ordine inviato!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Il tuo numero ordine è',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '#$numero',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attendi che il numero venga chiamato',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  // Pulisce il carrello e torna al menu per un nuovo ordine
                  onPressed: () {
                    cart.clear();
                    context.go('/menu');
                  },
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Nuovo ordine',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
