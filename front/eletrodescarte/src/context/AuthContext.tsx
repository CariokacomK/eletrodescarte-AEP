import { createContext, useState, useContext, useEffect, type ReactNode } from 'react';
import type { Usuario, LoginDTO } from '../types';
import { fazerLogin as apiLogin } from '../services/apiService';

interface AuthContextType {
  usuario: Usuario | null; 
  login: (data: LoginDTO) => Promise<void>; 
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType>(null!);

export function useAuth() {
  return useContext(AuthContext);
}

type Props = { children: ReactNode };

export function AuthProvider({ children }: Props) {
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const usuarioSalvo = localStorage.getItem('usuarioLogado');
    if (usuarioSalvo) {
      setUsuario(JSON.parse(usuarioSalvo));
    }
    setLoading(false);
  }, []);

  const login = async (data: LoginDTO) => {
    const usuarioLogado = await apiLogin(data);
    localStorage.setItem('usuarioLogado', JSON.stringify(usuarioLogado)); 
    setUsuario(usuarioLogado);
  };

  const logout = () => {
    localStorage.removeItem('usuarioLogado');
    setUsuario(null);
  };

  const value = {
    usuario,
    login,
    logout,
    loading,
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
}