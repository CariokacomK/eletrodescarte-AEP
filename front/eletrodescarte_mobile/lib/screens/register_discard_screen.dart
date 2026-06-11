import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterDiscardScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final List<dynamic> pontosColeta;

  const RegisterDiscardScreen({
    super.key,
    required this.usuario,
    required this.pontosColeta,
  });

  @override
  State<RegisterDiscardScreen> createState() => _RegisterDiscardScreenState();
}

class _RegisterDiscardScreenState extends State<RegisterDiscardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _obsController = TextEditingController();

  int? _idPontoSelecionado;
  int? _idMaterialSelecionado;
  List<dynamic> _materiais = [];
  
  bool _isLoadingMateriais = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Resultado da simulação de impacto após cadastro com sucesso
  Map<String, dynamic>? _simulacaoResultado;

  @override
  void initState() {
    super.initState();
    _loadMateriais();
    if (widget.pontosColeta.isNotEmpty) {
      _idPontoSelecionado = widget.pontosColeta.first['idPonto'];
    }
  }

  Future<void> _loadMateriais() async {
    try {
      final materiais = await ApiService.listarMateriais();
      setState(() {
        _materiais = materiais;
        if (materiais.isNotEmpty) {
          _idMaterialSelecionado = materiais.first['idMaterial'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar tipos de resíduos.';
      });
    } finally {
      setState(() {
        _isLoadingMateriais = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idPontoSelecionado == null || _idMaterialSelecionado == null) {
      setState(() {
        _errorMessage = 'Selecione o ponto e o tipo de material.';
      });
      return;
    }

    final double? peso = double.tryParse(_pesoController.text.replaceFirst(',', '.'));
    if (peso == null || peso <= 0) {
      setState(() {
        _errorMessage = 'O peso inserido deve ser maior que zero.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final resultado = await ApiService.registrarDescarte(
        idUsuario: widget.usuario['idUsuario'],
        idPonto: _idPontoSelecionado!,
        idMaterial: _idMaterialSelecionado!,
        quantidadeKg: peso,
        observacoes: _obsController.text.trim(),
      );

      setState(() {
        _simulacaoResultado = resultado;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text('Registrar Descarte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // Se já tiver feito uma simulação com sucesso, volta atualizando
            Navigator.pop(context, _simulacaoResultado != null);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_simulacaoResultado == null) ...[
                const Text(
                  'Novo Descarte Ecológico',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Insira os dados corretos abaixo para simular e salvar seu impacto.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Ponto de Coleta Dropdown
                        const Text('Ponto de Coleta Destino', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _idPontoSelecionado,
                              dropdownColor: const Color(0xFF203A43),
                              style: const TextStyle(color: Colors.white),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                              items: widget.pontosColeta.map((ponto) {
                                return DropdownMenuItem<int>(
                                  value: ponto['idPonto'],
                                  child: Text(ponto['nome'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _idPontoSelecionado = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Material Dropdown
                        const Text('Tipo de Resíduo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        _isLoadingMateriais
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF87)))
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _idMaterialSelecionado,
                                    dropdownColor: const Color(0xFF203A43),
                                    style: const TextStyle(color: Colors.white),
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                    items: _materiais.map((mat) {
                                      return DropdownMenuItem<int>(
                                        value: mat['idMaterial'],
                                        child: Text(mat['nome'] ?? ''),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _idMaterialSelecionado = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),

                        // Peso (kg) Input
                        TextFormField(
                          controller: _pesoController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Quantidade (Peso em Kg)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            suffixText: 'Kg',
                            suffixStyle: const TextStyle(color: Color(0xFF00FF87)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00FF87)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o peso';
                            }
                            final double? val = double.tryParse(value.replaceFirst(',', '.'));
                            if (val == null || val <= 0) {
                              return 'O peso deve ser maior que zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Observações
                        TextFormField(
                          controller: _obsController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Observações (Opcional)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00FF87)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Save Button
                        ElevatedButton(
                          onPressed: _isSaving ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                                )
                              : const Text(
                                  'Registrar & Simular Impacto',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Simulador de Impacto Ambiental Result Card
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF87),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Descarte Registrado com Sucesso!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Veja os resultados da simulação do seu impacto ecológico:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Impact Simulation Display
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildResultRow(
                              'E-Lixo Descartado:',
                              '${(_simulacaoResultado!['totalKg'] ?? 0.0).toString()} Kg',
                              Icons.scale_rounded,
                              const Color(0xFF00FF87),
                            ),
                            const Divider(color: Colors.white24, height: 28),
                            _buildResultRow(
                              'Emissão CO₂ Evitada:',
                              '${(_simulacaoResultado!['co2Evitado'] ?? 0.0).toString()} Kg CO₂e',
                              Icons.cloud_done_rounded,
                              const Color(0xFF81C784),
                            ),
                            const Divider(color: Colors.white24, height: 28),
                            _buildResultRow(
                              'Água Economizada:',
                              '${(_simulacaoResultado!['aguaEconomizada'] ?? 0.0).toString()} Litros',
                              Icons.water_drop_rounded,
                              const Color(0xFF64B5F6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Return Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Voltar ao Dashboard',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
