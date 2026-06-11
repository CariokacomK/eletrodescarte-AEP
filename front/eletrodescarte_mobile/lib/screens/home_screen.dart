import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_discard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _pontosColeta = [];
  bool _isLoadingPontos = true;
  
  // Indicadores
  double _totalKg = 0.0;
  double _co2Evitado = 0.0;
  double _aguaEconomizada = 0.0;
  bool _isLoadingIndicadores = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingPontos = true;
      _isLoadingIndicadores = true;
      _errorMessage = null;
    });

    final int idUsuario = widget.usuario['idUsuario'];

    // Buscar Indicadores
    try {
      final indicadores = await ApiService.obterIndicadores(idUsuario);
      setState(() {
        _totalKg = (indicadores['totalKgDescartado'] ?? 0.0).toDouble();
        _co2Evitado = (indicadores['totalCo2Evitado'] ?? 0.0).toDouble();
        _aguaEconomizada = (indicadores['totalAguaEconomizada'] ?? 0.0).toDouble();
      });
    } catch (e) {
      // Se não houver descartes, os indicadores retornam vazios ou falham
      setState(() {
        _totalKg = 0.0;
        _co2Evitado = 0.0;
        _aguaEconomizada = 0.0;
      });
    } finally {
      setState(() {
        _isLoadingIndicadores = false;
      });
    }

    // Buscar Pontos de Coleta
    try {
      final pontos = await ApiService.listarPontosColeta();
      setState(() {
        _pontosColeta = pontos;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar pontos de coleta.';
      });
    } finally {
      setState(() {
        _isLoadingPontos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nomeUsuario = widget.usuario['nomeCompleto'] ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text('Dashboard Ecológico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00FF87),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Olá, $nomeUsuario!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Confira seu impacto positivo na natureza hoje.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Indicators Card Section
              _isLoadingIndicadores
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF87)))
                  : Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38ef7d).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.eco_rounded, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Seu Impacto Acumulado',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildImpactItem('${_totalKg.toStringAsFixed(1)} kg', 'E-Lixo Salvo', Icons.scale_rounded),
                              _buildImpactItem('${_co2Evitado.toStringAsFixed(1)} kg', 'CO₂ Evitado', Icons.cloud_queue_rounded),
                              _buildImpactItem('${_aguaEconomizada.toStringAsFixed(0)} L', 'Água Economizada', Icons.water_drop_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_pontosColeta.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aguardando carregamento dos pontos de coleta...')),
                      );
                      return;
                    }
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterDiscardScreen(
                          usuario: widget.usuario,
                          pontosColeta: _pontosColeta,
                        ),
                      ),
                    );
                    if (resultado == true) {
                      _loadData(); // Atualiza indicadores após registrar
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
                  label: const Text('Registrar Novo Descarte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF87),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Section Collection Points Title
              const Text(
                'Pontos de Coleta Ativos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Collection Points List
              _isLoadingPontos
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFF00FF87)),
                    ))
                  : _errorMessage != null
                      ? Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))
                      : _pontosColeta.isEmpty
                          ? const Text('Nenhum ponto de coleta ativo no momento.', style: TextStyle(color: Colors.white60))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pontosColeta.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final ponto = _pontosColeta[index];
                                final nome = ponto['nome'] ?? 'Ponto sem nome';
                                final endereco = ponto['endereco'] ?? 'Sem endereço';
                                final org = ponto['organizacao'] != null ? ponto['organizacao']['nome'] : 'Organização';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00FF87).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.location_on_rounded, color: Color(0xFF00FF87)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nome,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              org,
                                              style: const TextStyle(color: Color(0xFF00FF87), fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              endereco,
                                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
