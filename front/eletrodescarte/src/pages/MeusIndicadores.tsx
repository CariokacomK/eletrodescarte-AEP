import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { getIndicadores } from '../services/apiService';

import type { IndicadoresDTO } from '../types';
import styles from './MeusIndicadores.module.css';

export function MeusIndicadores() {
  const [indicadores, setIndicadores] = useState<IndicadoresDTO | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  
  const { usuario, loading: authLoading } = useAuth(); 
  
  const [pageLoading, setPageLoading] = useState(true);

  useEffect(() => {
    if (authLoading) {
      return; 
    }
    
    if (usuario) {
      console.log("Usuário logado encontrado, buscando indicadores para ID:", usuario.idUsuario);

      getIndicadores(usuario.idUsuario)
        .then(data => {
          console.log("Dados recebidos da API:", data);
          setIndicadores(data);
        })
        .catch(err => {
          console.error("ERRO AO BUSCAR INDICADORES:", err);
          setErro("Não foi possível carregar seus indicadores.");
        })
        .finally(() => {
          setPageLoading(false); 
        });
    } else {
      setErro("Usuário não encontrado.");
      setPageLoading(false);
    }
    
  }, [usuario, authLoading]);

  if (pageLoading) {
    return <h3 className={styles.loading}>Calculando seu impacto... 📊</h3>;
  }
  
  if (erro) {
    return <p className={styles.error}>{erro}</p>;
  }
  
  if (!indicadores) {
    return <p className={styles.loading}>Sem dados de indicadores para exibir.</p>
  }

  return (
    <section>
      <header className={styles.pageHeader}>
        <h2>Seu Impacto Positivo, {usuario?.nomeCompleto.split(' ')[0]}!</h2>
        <p>Veja o quanto você já contribuiu para o meio ambiente:</p>
      </header>

      <main className={styles.grid}>
        
        <div className={styles.kpiCard}>
          <h3>Total Descartado</h3>
          <span className={styles.kpiValue}>
            {indicadores?.totalKgDescartado.toFixed(2)}
          </span>
          <span className={styles.kpiUnit}>Kg</span>
        </div>

        <div className={styles.kpiCard}>
          <h3>CO² Evitado</h3>
          <span className={styles.kpiValue}>
            {indicadores?.totalCo2Evitado.toFixed(2)}
          </span>
          <span className={styles.kpiUnit}>Kg</span>
        </div>

        <div className={styles.kpiCard}>
          <h3>Água Economizada</h3>
          <span className={styles.kpiValue}>
            {indicadores?.totalAguaEconomizada.toFixed(2)}
          </span>
          <span className={styles.kpiUnit}>Litros</span>
        </div>

      </main>
    </section>
  );
}