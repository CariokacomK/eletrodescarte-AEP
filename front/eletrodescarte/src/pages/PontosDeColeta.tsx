import { useState, useEffect } from 'react';
import { getPontosDeColeta } from '../services/apiService';

import type { PontoColeta, HorarioFuncionamento } from '../types';

import styles from './PontosDeColeta.module.css';

function PontoCard({ ponto }: { ponto: PontoColeta }) {
  
  const formatarHorarios = (horarios: HorarioFuncionamento[]) => {
    const dias = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];
    if (!horarios || horarios.length === 0) {
      return "Horário não informado.";
    }
    return horarios
      .map(h => `${dias[h.diaSemana]}: ${h.abreAs} - ${h.fechaAs}`)
      .join(', ');
  }

  return (
    <div className={styles.card}>
      <h3 className={styles.cardTitle}>{ponto.nome}</h3>
      <p><strong>Endereço:</strong> {ponto.endereco}, {ponto.cidade.nome}-{ponto.cidade.uf}</p>
      <p><strong>Organização:</strong> {ponto.organizacao.nome}</p>
      <p><strong>Contato:</strong> {ponto.telefone || ponto.email || 'Não informado'}</p>
      <p><strong>Horários:</strong> {formatarHorarios(ponto.horarios)}</p>
      
      <strong>Aceita:</strong>
      <div className={styles.badgeContainer}>
        {ponto.materiaisAceitos.map(m => (
          <span key={m.idMaterial} className={styles.badge}>{m.nome}</span>
        ))}
      </div>
    </div>
  );
}


export function PontosDeColeta() {
  const [pontos, setPontos] = useState<PontoColeta[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getPontosDeColeta()
      .then(data => {
        setPontos(data);
      })
      .catch(err => {
        console.error("Erro ao buscar pontos:", err);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  return (
    <section>
      <header className={styles.pageHeader}>
        <h2>Pontos de Coleta</h2>
        <p>Encontre o local mais próximo para o descarte correto do seu e-lixo.</p>
      </header>

      {loading && <h3 className={styles.loading}>Carregando pontos... 🌍</h3>}

      {!loading && (
        <div className={styles.grid}>
          {pontos.length === 0 ? (
            <p className={styles.loading}>Nenhum ponto de coleta encontrado.</p>
          ) : (
            pontos.map(ponto => (
              <PontoCard key={ponto.idPonto} ponto={ponto} />
            ))
          )}
        </div>
      )}
    </section>
  );
}