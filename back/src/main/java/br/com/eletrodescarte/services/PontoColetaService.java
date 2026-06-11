package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.PontoColeta;
import br.com.eletrodescarte.repositories.PontoColetaRepository;
import br.com.eletrodescarte.utils.QuickSortUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class PontoColetaService {

    @Autowired
    private PontoColetaRepository pontoColetaRepository;

    public List<PontoColeta> listarPontosAtivos() {
        List<PontoColeta> pontos = new ArrayList<>(pontoColetaRepository.findByAtivoTrue());
        QuickSortUtil.sort(pontos);
        return pontos;
    }
}