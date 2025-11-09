import type { CadastroDTO, LoginDTO, Usuario, PontoColeta, ConteudoEducativo, IndicadoresDTO, Cidade } from '../types';

const API_URL = 'http://localhost:8080/api';


export async function fazerLogin(data: LoginDTO): Promise<Usuario> {
  const response = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!response.ok) throw new Error('Falha no login');
  return response.json();
}

export async function cadastrarUsuario(data: CadastroDTO): Promise<Usuario> {
  const response = await fetch(`${API_URL}/auth/cadastrar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!response.ok) throw new Error('Falha no cadastro');
  return response.json();
}

export async function getPontosDeColeta(): Promise<PontoColeta[]> {
  const response = await fetch(`${API_URL}/pontos-coleta`);
  if (!response.ok) throw new Error('Falha ao buscar pontos');
  return response.json();
}

export async function getConteudos(): Promise<ConteudoEducativo[]> {
  const response = await fetch(`${API_URL}/conteudos`);
  if (!response.ok) throw new Error('Falha ao buscar conteúdos');
  return response.json();
}

export async function getIndicadores(userId: number): Promise<IndicadoresDTO> {
  const response = await fetch(`${API_URL}/indicadores/usuario/${userId}`);
  if (!response.ok) throw new Error('Falha ao buscar indicadores');
  return response.json();
}


export async function getCidades(): Promise<Cidade[]> {
  const response = await fetch(`${API_URL}/cidades`); 
  if (!response.ok) throw new Error('Falha ao buscar cidades');
  return response.json();
}