import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_model.dart';
import '../models/categoria.dart';
import '../models/prodotto.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

// Schermata principale del totem: mostra le categorie e i prodotti disponibili
class MenuPage extends StatefulWidget {
  final CartModel cart;

  const MenuPage({super.key, required this.cart});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Categoria> _categorie = [];
  List<Prodotto> _prodotti = [];
  int? _selectedCategoriaId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategorie();
  }

  Future<void> _loadCategorie() async {
    try {
      final cats = await ApiService.getCategorie();
      setState(() {
        _categorie = cats;
        _selectedCategoriaId = cats.isNotEmpty ? cats.first.id : null;
        _loading = false;
      });
      if (_selectedCategoriaId != null) {
        await _loadProdotti(_selectedCategoriaId!);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadProdotti(int categoriaId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prods = await ApiService.getProdottiByCategoria(categoriaId);
      setState(() {
        _prodotti = prods;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // Icona carrello con badge che mostra il numero di prodotti
          ListenableBuilder(
            listenable: widget.cart,
            builder: (context, _) {
              final count = widget.cart.count;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.go('/cart'),
                    tooltip: 'Carrello',
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Riga scrollabile con le categorie come chip selezionabili
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categorie.length,
              itemBuilder: (context, i) {
                final cat = _categorie[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.nome),
                    selected: cat.id == _selectedCategoriaId,
                    selectedColor: Colors.orange,
                    onSelected: (_) {
                      setState(() => _selectedCategoriaId = cat.id);
                      _loadProdotti(cat.id);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Griglia prodotti della categoria selezionata
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Colors.orange));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadCategorie(),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    if (_prodotti.isEmpty) {
      return const Center(child: Text('Nessun prodotto disponibile'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _prodotti.length,
      itemBuilder: (context, i) => ProductCard(
        prodotto: _prodotti[i],
        cart: widget.cart,
      ),
    );
  }
}
