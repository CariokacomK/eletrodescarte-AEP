import { Link } from 'react-router-dom';

import { FaMapMarkedAlt, FaBook } from 'react-icons/fa';
import styles from './Home.module.css'; 
import heroImageUrl from '../assets/eletro-hero.svg';

export function Home() {
  return (
    <div className={styles.heroContainer}>
      
      <div className={styles.heroContent}>
        <h1 className={styles.heroTitle}>
          Transforme seu E-Lixo em Impacto Positivo.
        </h1>
        
        <p className={styles.heroSubtitle}>
          Encontre o ponto de coleta mais próximo e ajude a construir 
          um futuro mais sustentável para todos.
        </p>

        <div className={styles.buttonContainer}>
          
          <Link to="/pontos-de-coleta" className={styles.ctaButton}>
            <FaMapMarkedAlt />
            Encontrar Pontos
          </Link>
          
          <Link to="/educativo" className={styles.secondaryButton}>
            <FaBook />
            Aprender Mais
          </Link>

        </div>
      </div>

      <div className={styles.heroImageContainer}>
        <img 
          src={heroImageUrl} 
          className={styles.heroImage} 
          alt="Ilustração de reciclagem de eletrônicos" 
        />
      </div>

    </div>
  );
}