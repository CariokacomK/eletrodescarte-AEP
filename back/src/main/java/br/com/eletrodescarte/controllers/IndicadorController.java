package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.services.IndicadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/indicadores")
public class IndicadorController {

    @Autowired
    private IndicadorService indicadorService;

    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<IndicadorService.IndicadoresDTO> getIndicadoresDoUsuario(
            @PathVariable Long idUsuario
    ) {
        try {
            IndicadorService.IndicadoresDTO indicadores =
                    indicadorService.calcularIndicadoresPorUsuario(idUsuario);

            return ResponseEntity.ok(indicadores);

        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}