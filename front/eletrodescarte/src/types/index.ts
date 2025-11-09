export interface Cidade {
  idCidade: number;
  nome: string;
  uf: string;
}

export interface Organizacao {
  nome: string;
}

export interface HorarioFuncionamento {
  diaSemana: number;
  abreAs: string;
  fechaAs: string;
}

export interface Material {
  idMaterial: number;
  nome: string;
}

export interface PontoColeta {
  idPonto: number;
  nome: string;
  endereco: string;
  telefone: string;
  email: string;
  cidade: Cidade;
  organizacao: Organizacao;
  horarios: HorarioFuncionamento[];
  materiaisAceitos: Material[];
}

export interface ConteudoEducativo {
  idConteudo: number;
  titulo: string;
  slug: string;
  corpoMd: string;
  nivel: 'basico' | 'intermediario' | 'avancado';
}

export interface Usuario {
  idUsuario: number;
  nomeCompleto: string;
  email: string;
  papel: 'cidadao' | 'admin' | 'moderador';
}

export interface IndicadoresDTO {
  totalKgDescartado: number;
  totalCo2Evitado: number;
  totalAguaEconomizada: number;
}

export interface CadastroDTO {
  nomeCompleto: string;
  email: string;
  senha: string;
  idCidade: number | null;
}

export interface LoginDTO {
  email: string;
  senha: string;
}