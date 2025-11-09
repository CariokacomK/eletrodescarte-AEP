import { FaSignInAlt, FaSignOutAlt, FaUserPlus } from 'react-icons/fa';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import styles from './Navbar.module.css';

import { useAuth } from '../../context/AuthContext';

export function Navbar() {
  const { usuario, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login'); 
  };

  const getNavLinkClass = ({ isActive }: { isActive: boolean }) => {
    return isActive ? styles.active : styles.navLink;
  };

  return (
    <nav className={styles.navbar}>
      
      <Link to="/" className={styles.logo}>
        Eletrodescarte
      </Link>

      <div className={styles.navLinks}>
        <NavLink to="/" className={getNavLinkClass} end>
          Home
        </NavLink>
        <NavLink to="/pontos-de-coleta" className={getNavLinkClass}>
          Pontos de Coleta
        </NavLink>
        <NavLink to="/educativo" className={getNavLinkClass}>
          Educativo
        </NavLink>
        
        {usuario && (
          <NavLink to="/meus-indicadores" className={getNavLinkClass}>
            Meus Indicadores
          </NavLink>
        )}
      </div>

      <div className={styles.authLinks}>
        {usuario ? (
          <div className={styles.loggedInContainer}>
            <span className={styles.welcomeMessage}>
              Olá, {usuario.nomeCompleto.split(' ')[0]}!
            </span>
            <button onClick={handleLogout} className={styles.logoutButton}>
              <FaSignOutAlt />
              <span>Sair</span>
            </button>
          </div>
        ) : (
          <>
            <Link to="/login" className={styles.loginButton}>
              <FaSignInAlt />
              <span>Login</span>
            </Link>
            <Link to="/cadastrar" className={styles.registerButton}>
              <FaUserPlus />
              <span>Cadastrar</span>
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}