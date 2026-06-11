import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/ponto_coleta.dart';
import '../services/api_service.dart';

class MapTab extends StatefulWidget {
  final Usuario usuario;

  const MapTab({super.key, required this.usuario});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  
  List<PontoColeta> _todosPontos = [];
  List<PontoColeta> _pontosFiltrados = [];
  bool _isLoading = true;
  String _filtroMaterial = "Todos";

  @override
  void initState() {
    super.initState();
    _loadPontos();
    _searchController.addListener(_filtrarPontos);
  }

  Future<void> _loadPontos() async {
    try {
      final pontos = await _apiService.buscarPontosColeta();
      setState(() {
        _todosPontos = pontos;
        _pontosFiltrados = pontos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao buscar pontos: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _filtrarPontos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _pontosFiltrados = _todosPontos.where((ponto) {
        final matchQuery = ponto.nome.toLowerCase().contains(query) ||
            ponto.endereco.toLowerCase().contains(query);
            
        final matchMaterial = _filtroMaterial == "Todos" ||
            ponto.materiaisAceitos.any((m) => m.nome == _filtroMaterial);

        return matchQuery && matchMaterial;
      }).toList();
    });
  }

  bool _isPointOpen(PontoColeta p) {
    if (!p.ativo) return false;
    if (p.horarios.isEmpty) return true;
    final now = DateTime.now();
    final diaAtual = now.weekday; // Segunda = 1, Domingo = 7

    final horarioDia = p.horarios.firstWhere(
      (h) => h.diaSemana == diaAtual,
      orElse: () => p.horarios.first,
    );
    
    try {
      final abreParts = horarioDia.abreAs.split(':');
      final fechaParts = horarioDia.fechaAs.split(':');
      
      final abreMinutos = int.parse(abreParts[0]) * 60 + int.parse(abreParts[1]);
      final fechaMinutos = int.parse(fechaParts[0]) * 60 + int.parse(fechaParts[1]);
      final agoraMinutos = now.hour * 60 + now.minute;
      
      return agoraMinutos >= abreMinutos && agoraMinutos <= fechaMinutos;
    } catch (e) {
      return true;
    }
  }

  // Gera uma distância aproximada baseada na latitude/longitude ou uma distância fictícia fixa para o mockup
  double _getMockDistance(PontoColeta p) {
    if (p.latitude != null && p.longitude != null) {
      // Cálculo simples de distância euclidiana multiplicada para parecer em km
      // (usando como centro fictício a cidade do usuário)
      final userLat = widget.usuario.cidade?.nome.toLowerCase() == "curitiba" ? -25.4284 : -23.4210; // Curitiba ou Maringá
      final userLng = widget.usuario.cidade?.nome.toLowerCase() == "curitiba" ? -49.2733 : -51.9331;
      
      final dLat = p.latitude! - userLat;
      final dLng = p.longitude! - userLng;
      final dist = (dLat * dLat + dLng * dLng) * 10;
      return double.parse((dist + 1.2).toStringAsFixed(1)); // Garante uma distância mínima realista
    }
    
    // Distâncias padrão baseadas no mock
    if (p.nome.contains("Pinheiros")) return 1.2;
    if (p.nome.contains("Mada")) return 2.5;
    if (p.nome.contains("Jardins")) return 3.8;
    return 4.2;
  }

  List<String> _getTodosMateriaisUnicos() {
    final lista = <String>["Todos"];
    for (var p in _todosPontos) {
      for (var m in p.materiaisAceitos) {
        if (!lista.contains(m.nome)) {
          lista.add(m.nome);
        }
      }
    }
    return lista;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1ECB71);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Pontos de Coleta",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Input Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Buscar ponto de coleta...",
                        hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Map Mockup Container
                Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDEE2E6)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid Pattern for Map mock
                      Positioned.fill(
                        child: GridPaper(
                          color: const Color(0xFFCED4DA).withOpacity(0.25),
                          interval: 40.0,
                          divisions: 1,
                          subdivisions: 1,
                        ),
                      ),
                      // Decorative Pins
                      const Positioned(
                        top: 40,
                        left: 60,
                        child: Icon(Icons.location_on, color: primaryGreen, size: 28),
                      ),
                      const Positioned(
                        top: 70,
                        right: 80,
                        child: Icon(Icons.location_on, color: Colors.green, size: 24),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 40,
                        child: Icon(Icons.location_on, color: Colors.blue[400], size: 28),
                      ),
                      // Central Mock Indicator
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ]
                            ),
                            child: const Icon(Icons.close, color: Color(0xFFADB5BD), size: 26),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "VISUALIZAÇÃO DO MAPA",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C757D),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Locais Próximos Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Locais Próximos",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Encontrados ${_pontosFiltrados.length} pontos perto de você",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      // Filter Badge/Menu
                      PopupMenuButton<String>(
                        onSelected: (String material) {
                          setState(() {
                            _filtroMaterial = material;
                            _filtrarPontos();
                          });
                        },
                        itemBuilder: (context) {
                          return _getTodosMateriaisUnicos().map((String mat) {
                            return PopupMenuItem<String>(
                              value: mat,
                              child: Row(
                                children: [
                                  Icon(
                                    mat == "Todos" ? Icons.category : Icons.recycling, 
                                    size: 16, 
                                    color: _filtroMaterial == mat ? primaryGreen : Colors.grey
                                  ),
                                  const SizedBox(width: 8),
                                  Text(mat, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F9F0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _filtroMaterial == "Todos" ? "Filtrar" : _filtroMaterial,
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.filter_list, color: primaryGreen, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Collection Points List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _pontosFiltrados.length,
                    itemBuilder: (context, index) {
                      final ponto = _pontosFiltrados[index];
                      final isOpen = _isPointOpen(ponto);
                      final distance = _getMockDistance(ponto);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Avatar representation
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFF1F3F5),
                              child: Icon(
                                Icons.storefront, 
                                color: isOpen ? primaryGreen : const Color(0xFFADB5BD), 
                                size: 20
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ponto.nome,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212529),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Status Text/Badge
                                      if (isOpen)
                                        const Text(
                                          "Aberto",
                                          style: TextStyle(
                                            color: primaryGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF0F1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "Fechado",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ponto.endereco,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C757D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Badges row
                                  Row(
                                    children: [
                                      // Distance
                                      Icon(Icons.location_on_outlined, color: Colors.green[700], size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$distance km",
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                                      ),
                                      const SizedBox(width: 14),
                                      // Hours
                                      const Icon(Icons.access_time, color: Colors.blue, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        ponto.horarioFormatado,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Action Button / Arrow
                            IconButton(
                              onPressed: () {
                                _mostrarOpcoesPonto(ponto);
                              },
                              icon: Icon(
                                Icons.near_me_outlined, 
                                color: isOpen ? primaryGreen : const Color(0xFFADB5BD)
                              ),
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Support Alert Box (Bottom)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryGreen.withOpacity(0.15),
                        child: const Icon(Icons.phone_in_talk, color: primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Suporte ao Descarte",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF155724),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Tem dúvidas sobre o que pode ser descartado? Ligue para o ponto de coleta antes de ir.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF212529),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _mostrarOpcoesPonto(PontoColeta p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                p.nome,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(p.endereco, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text("Materiais Aceitos:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: p.materiaisAceitos.map((m) {
                  return Chip(
                    label: Text(m.nome, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green.withOpacity(0.08),
                    side: BorderSide(color: Colors.green.withOpacity(0.2)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Abrindo rota de navegação... (Mock)")),
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text("Como Chegar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ECB71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (p.telefone != null && p.telefone!.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ligando para ${p.telefone}... (Mock)")),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: Text("Ligar: ${p.telefone}"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1ECB71),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF1ECB71)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
