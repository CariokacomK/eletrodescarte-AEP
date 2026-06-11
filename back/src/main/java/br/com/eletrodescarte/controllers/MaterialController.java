package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.Material;
import br.com.eletrodescarte.services.MaterialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/materiais")
public class MaterialController {

    @Autowired
    private MaterialService materialService;

    @GetMapping
    public ResponseEntity<List<Material>> getMateriais() {
        List<Material> materiais = materialService.listarMateriais();
        return ResponseEntity.ok(materiais);
    }
}
