import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { cadastrarUsuario, getCidades } from '../services/apiService';

import type { CadastroDTO, Cidade } from '../types';

import styles from './Form.module.css';

export function Cadastro() {
  const [nomeCompleto, setNome] = useState('');
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [idCidade, setIdCidade] = useState<number | null>(null);
  
  const [cidades, setCidades] = useState<Cidade[]>([]);
  const [erro, setErro] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    async function carregarCidades() {
      try {
        const listaCidades = await getCidades();
        setCidades(listaCidades);
      } catch (err) {
        setErro('Não foi possível carregar as cidades. Tente recarregar a página.');
      }
    }
    carregarCidades();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErro(null);
    if (!idCidade) {
      setErro("Por favor, selecione uma cidade.");
      return;
    }

    const data: CadastroDTO = { nomeCompleto, email, senha, idCidade };

    try {
      await cadastrarUsuario(data);
      alert('Cadastro realizado com sucesso! Faça o login.');
      navigate('/login');
    } catch (err) {
      setErro('E-mail já cadastrado ou falha no servidor.');
    }
  };

  return (
    <div className={styles.formContainer}>
      <h2>Crie sua Conta</h2>
      <form onSubmit={handleSubmit}>
        <div className={styles.inputGroup}>
          <label htmlFor="nome">Nome Completo</label>
          <input
            id="nome"
            type="text"
            className={styles.input}
            value={nomeCompleto}
            onChange={(e) => setNome(e.target.value)}
            required
          />
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            className={styles.input}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="senha">Senha</label>
          <input
            id="senha"
            type="password"
            className={styles.input}
            value={senha}
            onChange={(e) => setSenha(e.target.value)}
            minLength={6}
            required
          />
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="cidade">Sua Cidade</label>
          <select
            id="cidade"
            className={styles.select}
            value={idCidade || ''}
            onChange={(e) => setIdCidade(Number(e.target.value))}
            required
          >
            <option value="" disabled>Selecione...</option>
            {cidades.map(c => (
              <option key={c.idCidade} value={c.idCidade}>
                {c.nome} - {c.uf}
              </option>
            ))}
          </select>
        </div>
        
        {erro && <p className={styles.error}>{erro}</p>}
        
        <button type="submit" className={styles.button}>Cadastrar</button>
      </form>
      <p style={{ textAlign: 'center', marginTop: '1.5rem' }}>
        Já tem uma conta? <Link to="/login">Faça Login</Link>
      </p>
    </div>
  );
}