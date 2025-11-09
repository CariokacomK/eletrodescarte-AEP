import { useState, useEffect } from 'react';
import { getConteudos } from '../services/apiService';

import type { ConteudoEducativo } from '../types';

import styles from './Educativo.module.css';

export function Educativo() {
  const [conteudos, setConteudos] = useState<ConteudoEducativo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getConteudos()
      .then(setConteudos)
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  }, []);

  return (
    <section>
      <header className={styles.pageHeader}>
        <h2>Área Educativa</h2>
        <p>Aprenda sobre o impacto do e-lixo e a forma correta de descarte.</p>
      </header>

      {loading && <h3 className={styles.loading}>Carregando conteúdo... 📚</h3>}

      {!loading && (
        <main>
          {conteudos.length === 0 ? (
            <p className={styles.loading}>Nenhum conteúdo educativo encontrado.</p>
          ) : (
            conteudos.map(c => (
              <article key={c.idConteudo} className={styles.card}>
                <span className={styles.badge}>{c.nivel}</span>
                <h3 className={styles.cardTitle}>{c.titulo}</h3>
                
                <p className={styles.cardBody}>
                  {c.corpoMd.substring(0, 200)}...
                </p>
                
                <a href={`/educativo/${c.slug}`} className={styles.link}>
                  Ler mais →
                </a>
              </article>
            ))
          )}
        </main>
      )}
    </section>
  );
}