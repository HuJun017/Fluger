import 'package:flutter/material.dart';
import 'models/cart_model.dart';
import 'app_router.dart';

void main() {
  runApp(const TotemApp());
}

// StatefulWidget perché dobbiamo mantenere vivi CartModel e GoRouter
// per tutto il ciclo di vita dell'app senza ricrearli ad ogni build
class TotemApp extends StatefulWidget {
  const TotemApp({super.key});

  @override
  State<TotemApp> createState() => _TotemAppState();
}

class _TotemAppState extends State<TotemApp> {
  // Il carrello viene creato qui e passato al router, così è condiviso
  // tra tutte le pagine senza bisogno di librerie di state management esterne
  final CartModel _cart = CartModel();
  late final _router = buildRouter(_cart);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hamburgeria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
