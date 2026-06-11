package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class DescarteService {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PontoColetaRepository pontoColetaRepository;

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private FatoresMateriaisRepository fatoresRepository;

    public record ItemDescarteDTO(Long idMaterial, BigDecimal quantidadeKg) {}

    public record NovoDescarteRequestDTO(
            Long idUsuario,
            Long idPonto,
            String observacoes,
            List<ItemDescarteDTO> itens
    ) {}

    public record SimulacaoImpactoDTO(
            Long idDescarte,
            BigDecimal totalKg,
            BigDecimal co2Evitado,
            BigDecimal aguaEconomizada
    ) {}

    @Transactional
    public SimulacaoImpactoDTO registrarDescarte(NovoDescarteRequestDTO request) {
        if (request.idUsuario() == null) {
            throw new IllegalArgumentException("ID do usuário é obrigatório.");
        }
        if (request.idPonto() == null) {
            throw new IllegalArgumentException("ID do ponto de coleta é obrigatório.");
        }
        if (request.itens() == null || request.itens().isEmpty()) {
            throw new IllegalArgumentException("O descarte deve conter pelo menos um item.");
        }

        Usuario usuario = usuarioRepository.findById(request.idUsuario())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado."));

        PontoColeta pontoColeta = pontoColetaRepository.findById(request.idPonto())
                .orElseThrow(() -> new IllegalArgumentException("Ponto de coleta não encontrado."));

        Descarte descarte = new Descarte();
        descarte.setUsuario(usuario);
        descarte.setPontoColeta(pontoColeta);
        descarte.setObservacoes(request.observacoes());

        List<DescarteItem> itensEntidade = new ArrayList<>();
        BigDecimal totalKg = BigDecimal.ZERO;
        BigDecimal co2Evitado = BigDecimal.ZERO;
        BigDecimal aguaEconomizada = BigDecimal.ZERO;

        for (ItemDescarteDTO itemDTO : request.itens()) {
            if (itemDTO.idMaterial() == null) {
                throw new IllegalArgumentException("ID do material é obrigatório.");
            }
            if (itemDTO.quantidadeKg() == null || itemDTO.quantidadeKg().compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("A quantidade em Kg deve ser maior que zero.");
            }

            Material material = materialRepository.findById(itemDTO.idMaterial())
                    .orElseThrow(() -> new IllegalArgumentException("Material não encontrado."));

            DescarteItem descarteItem = new DescarteItem();
            descarteItem.setDescarte(descarte);
            descarteItem.setMaterial(material);
            descarteItem.setQuantidadeKg(itemDTO.quantidadeKg());

            itensEntidade.add(descarteItem);

            totalKg = totalKg.add(itemDTO.quantidadeKg());

            Optional<FatoresMateriais> fatoresOpt = fatoresRepository.findById(material.getIdMaterial());
            if (fatoresOpt.isPresent()) {
                FatoresMateriais fatores = fatoresOpt.get();
                co2Evitado = co2Evitado.add(itemDTO.quantidadeKg().multiply(fatores.getCo2eKgPorKg()));
                aguaEconomizada = aguaEconomizada.add(itemDTO.quantidadeKg().multiply(fatores.getAguaLitrosPorKg()));
            }
        }

        descarte.setItens(itensEntidade);
        Descarte descarteSalvo = descarteRepository.save(descarte);

        return new SimulacaoImpactoDTO(
                descarteSalvo.getIdDescarte(),
                totalKg,
                co2Evitado,
                aguaEconomizada
        );
    }
}
