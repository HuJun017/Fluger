import 'package:go_router/go_router.dart';
import 'models/cart_model.dart';
import 'pages/menu_page.dart';
import 'pages/cart_page.dart';
import 'pages/confirm_page.dart';

// Costruisce il router passando il carrello condiviso a tutte le pagine.
// Il carrello è creato una sola volta in main.dart e passato qui —
// in questo modo tutte le schermate lavorano sullo stesso stato.
GoRouter buildRouter(CartModel cart) => GoRouter(
      initialLocation: '/menu',
      routes: [
        GoRoute(
          path: '/menu',
          builder: (context, state) => MenuPage(cart: cart),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => CartPage(cart: cart),
        ),
        GoRoute(
          path: '/confirm/:numero',
          builder: (context, state) {
            // Estrae il numero ordine dal path, es: /confirm/42 → numero = 42
            final numero = int.parse(state.pathParameters['numero']!);
            return ConfirmPage(numero: numero, cart: cart);
          },
        ),
      ],
    );
