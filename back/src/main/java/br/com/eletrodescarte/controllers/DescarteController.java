package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.services.IndicadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/descartes")
public class DescarteController {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private IndicadorService indicadorService;

    @PostMapping
    public ResponseEntity<Descarte> salvarDescarte(@RequestBody Descarte descarte) {
        if (descarte.getItens() != null) {
            descarte.getItens().forEach(item -> item.setDescarte(descarte));
        }
        Descarte novoDescarte = descarteRepository.save(descarte);
        return ResponseEntity.ok(novoDescarte);
    }

    @GetMapping("/usuario/{usuarioId}/indicadores")
    public ResponseEntity<IndicadorService.IndicadoresDTO> getIndicadores(@PathVariable Long usuarioId) {
        IndicadorService.IndicadoresDTO indicadores = indicadorService.calcularIndicadoresPorUsuario(usuarioId);
        return ResponseEntity.ok(indicadores);
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<Descarte>> listarPorUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(descarteRepository.findAll().stream()
                .filter(d -> d.getUsuario().getIdUsuario().equals(usuarioId))
                .toList());
    }
}