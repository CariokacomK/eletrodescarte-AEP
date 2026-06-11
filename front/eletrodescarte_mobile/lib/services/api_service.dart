import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 10.0.2.2 is the special IP for Android Emulator to access the host's localhost (Spring Boot on port 8080)
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Helper method for headers
  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
  }

  // 1. Cadastrar Usuário
  static Future<Map<String, dynamic>?> cadastrar({
    required String nomeCompleto,
    required String email,
    required String senha,
    required int idCidade,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/cadastrar'),
        headers: _headers(),
        body: jsonEncode({
          'nomeCompleto': nomeCompleto,
          'email': email,
          'senha': senha,
          'idCidade': idCidade,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(body['message'] ?? 'Falha no cadastro.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. Login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 401) {
        throw Exception('E-mail ou senha incorretos.');
      } else {
        throw Exception('Falha ao autenticar.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. Listar Cidades
  static Future<List<dynamic>> listarCidades() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cidades'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao listar cidades.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. Listar Pontos de Coleta Ativos
  static Future<List<dynamic>> listarPontosColeta() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pontos-coleta'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao listar pontos de coleta.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 5. Listar Materiais Aceitos
  static Future<List<dynamic>> listarMateriais() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materiais'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao listar tipos de resíduos.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 6. Buscar Indicadores Ambientais do Usuário
  static Future<Map<String, dynamic>> obterIndicadores(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/indicadores/usuario/$idUsuario'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao buscar indicadores.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 7. Registrar Novo Descarte (Simulador de Impacto)
  static Future<Map<String, dynamic>> registrarDescarte({
    required int idUsuario,
    required int idPonto,
    required int idMaterial,
    required double quantidadeKg,
    String observacoes = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/descartes'),
        headers: _headers(),
        body: jsonEncode({
          'idUsuario': idUsuario,
          'idPonto': idPonto,
          'observacoes': observacoes,
          'itens': [
            {
              'idMaterial': idMaterial,
              'quantidadeKg': quantidadeKg,
            }
          ]
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(body['message'] ?? 'Falha ao registrar descarte.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
