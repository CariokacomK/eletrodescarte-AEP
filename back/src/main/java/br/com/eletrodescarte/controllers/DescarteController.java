package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.services.DescarteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/descartes")
public class DescarteController {

    @Autowired
    private DescarteService descarteService;

    @PostMapping
    public ResponseEntity<DescarteService.SimulacaoImpactoDTO> registrarDescarte(
            @RequestBody DescarteService.NovoDescarteRequestDTO request
    ) {
        DescarteService.SimulacaoImpactoDTO simulacao = descarteService.registrarDescarte(request);
        return new ResponseEntity<>(simulacao, HttpStatus.CREATED);
    }
}
