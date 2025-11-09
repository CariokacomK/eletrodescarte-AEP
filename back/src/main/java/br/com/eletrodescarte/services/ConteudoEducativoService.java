package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.ConteudosEducativos;
import br.com.eletrodescarte.repositories.ConteudosEducativosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ConteudoEducativoService {

    @Autowired
    private ConteudosEducativosRepository conteudosRepository;

    public List<ConteudosEducativos> listarConteudosPublicados() {
        return conteudosRepository.findByPublicadoTrue();
    }
}