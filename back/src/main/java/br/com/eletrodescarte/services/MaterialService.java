package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Material;
import br.com.eletrodescarte.repositories.MaterialRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MaterialService {

    @Autowired
    private MaterialRepository materialRepository;

    public List<Material> listarMateriais() {
        return materialRepository.findAll();
    }
}
