import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';
import '../models/prodotto.dart';

class ApiService {
  static String _base = 'http://localhost:5000/api';

  static void setBaseUrl(String backendUrl) {
    _base = '$backendUrl/api';
  }

  static String imageProxyUrl(String originalUrl) =>
      '$_base/immagine?url=${Uri.encodeComponent(originalUrl)}';

  static Future<List<Categoria>> getCategorie() async {
    final res = await http.get(Uri.parse('$_base/categorie'));
    if (res.statusCode != 200) throw Exception('Errore caricamento categorie');
    final List data = jsonDecode(res.body);
    return data.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Prodotto>> getProdottiByCategoria(int categoriaId) async {
    final res = await http.get(Uri.parse('$_base/categorie/$categoriaId/prodotti'));
    if (res.statusCode != 200) throw Exception('Errore caricamento prodotti');
    final List data = jsonDecode(res.body);
    return data.map((e) => Prodotto.fromJson(e as Map<String, dynamic>)).toList();
  }

  // items: lista di { 'prodotto_id': int, 'quantita': int }
  static Future<Map<String, dynamic>> createOrdine(
      List<Map<String, int>> items) async {
    final res = await http.post(
      Uri.parse('$_base/ordini'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'items': items}),
    );
    if (res.statusCode != 201) throw Exception('Errore invio ordine');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
