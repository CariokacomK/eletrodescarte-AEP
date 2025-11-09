package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Cidade;
import br.com.eletrodescarte.repositories.CidadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CidadeService {

    @Autowired
    private CidadeRepository cidadeRepository;

    public List<Cidade> listarCidadesOrdenadas() {
        return cidadeRepository.findAllByOrderByNomeAsc();
    }
}