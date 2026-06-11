import 'material_model.dart';

class HorarioFuncionamento {
  final int idHorario;
  final int diaSemana;
  final String abreAs;
  final String fechaAs;

  HorarioFuncionamento({
    required this.idHorario,
    required this.diaSemana,
    required this.abreAs,
    required this.fechaAs,
  });

  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    return HorarioFuncionamento(
      idHorario: json['idHorario'] ?? json['id_horario'] ?? 0,
      diaSemana: json['diaSemana'] ?? json['dia_semana'] ?? 1,
      abreAs: json['abreAs'] ?? json['abre_as'] ?? '08:00:00',
      fechaAs: json['fechaAs'] ?? json['fecha_as'] ?? '18:00:00',
    );
  }

  String get diaFormatado {
    const dias = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    if (diaSemana >= 1 && diaSemana <= 7) {
      return dias[diaSemana - 1];
    }
    return 'Dia Útil';
  }
}

class PontoColeta {
  final int idPonto;
  final String nome;
  final String endereco;
  final double? latitude;
  final double? longitude;
  final String? telefone;
  final String? email;
  final bool ativo;
  final List<HorarioFuncionamento> horarios;
  final List<MaterialModel> materiaisAceitos;

  PontoColeta({
    required this.idPonto,
    required this.nome,
    required this.endereco,
    this.latitude,
    this.longitude,
    this.telefone,
    this.email,
    required this.ativo,
    required this.horarios,
    required this.materiaisAceitos,
  });

  factory PontoColeta.fromJson(Map<String, dynamic> json) {
    var listHorarios = json['horarios'] as List? ?? [];
    List<HorarioFuncionamento> horariosList = listHorarios
        .map((h) => HorarioFuncionamento.fromJson(h))
        .toList();

    var listMateriais = json['materiaisAceitos'] as List? ?? [];
    List<MaterialModel> materiaisList = listMateriais
        .map((m) => MaterialModel.fromJson(m))
        .toList();

    return PontoColeta(
      idPonto: json['idPonto'] ?? json['id_ponto'] ?? 0,
      nome: json['nome'] ?? '',
      endereco: json['endereco'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      telefone: json['telefone'],
      email: json['email'],
      ativo: json['ativo'] ?? true,
      horarios: horariosList,
      materiaisAceitos: materiaisList,
    );
  }

  String get horarioFormatado {
    if (horarios.isEmpty) {
      return '08:00 - 18:00';
    }
    final h = horarios.first;
    String formatTime(String time) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    }
    return '${formatTime(h.abreAs)} - ${formatTime(h.fechaAs)}';
  }
}
