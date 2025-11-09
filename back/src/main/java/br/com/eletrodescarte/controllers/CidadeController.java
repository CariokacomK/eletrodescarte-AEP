package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.Cidade;
import br.com.eletrodescarte.services.CidadeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/cidades")
public class CidadeController {

    @Autowired
    private CidadeService cidadeService;

    @GetMapping
    public ResponseEntity<List<Cidade>> getCidades() {
        List<Cidade> cidades = cidadeService.listarCidadesOrdenadas();
        return ResponseEntity.ok(cidades);
    }
}