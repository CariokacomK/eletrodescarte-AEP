import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import styles from './Form.module.css';

export function Login() {
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [erro, setErro] = useState<string | null>(null);
  
  const { login } = useAuth();
  const navigate = useNavigate(); 

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErro(null);
    try {
      await login({ email, senha });
      navigate('/meus-indicadores');
    } catch (err) {
      setErro('Email ou senha inválidos.');
    }
  };

  return (
    <div className={styles.formContainer}>
      <h2>Acessar Conta</h2>
      <form onSubmit={handleSubmit}>
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
            required
          />
        </div>
        
        {erro && <p className={styles.error}>{erro}</p>}
        
        <button type="submit" className={styles.button}>Entrar</button>
      </form>
      <p style={{ textAlign: 'center', marginTop: '1.5rem' }}>
        Não tem uma conta? <Link to="/cadastrar">Cadastre-se</Link>
      </p>
    </div>
  );
}