package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.ConteudosEducativos;
import br.com.eletrodescarte.services.ConteudoEducativoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/conteudos")
public class ConteudoEducativoController {

    @Autowired
    private ConteudoEducativoService conteudoService;

    @GetMapping
    public ResponseEntity<List<ConteudosEducativos>> listarConteudos() {
        List<ConteudosEducativos> conteudos = conteudoService.listarConteudosPublicados();
        return ResponseEntity.ok(conteudos);
    }
}