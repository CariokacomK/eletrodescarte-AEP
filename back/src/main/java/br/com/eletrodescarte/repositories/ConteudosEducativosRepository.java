package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.ConteudosEducativos;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConteudosEducativosRepository extends JpaRepository<ConteudosEducativos, Long> {
    List<ConteudosEducativos> findByPublicadoTrue();

    Optional<ConteudosEducativos> findBySlugAndPublicadoTrue(String slug);
}