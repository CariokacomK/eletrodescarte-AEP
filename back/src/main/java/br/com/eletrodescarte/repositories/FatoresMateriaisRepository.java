package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.FatoresMateriais;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FatoresMateriaisRepository extends JpaRepository<FatoresMateriais, Long> {
}