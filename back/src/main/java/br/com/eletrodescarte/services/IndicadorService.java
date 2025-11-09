package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.models.DescarteItem;
import br.com.eletrodescarte.models.FatoresMateriais;
import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.repositories.FatoresMateriaisRepository;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
public class IndicadorService {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private FatoresMateriaisRepository fatoresRepository;

    public record IndicadoresDTO(
            BigDecimal totalKgDescartado,
            BigDecimal totalCo2Evitado,
            BigDecimal totalAguaEconomizada
    ) {}

    public IndicadoresDTO calcularIndicadoresPorUsuario(Long idUsuario) {

        Optional<Usuario> usuarioOpt = usuarioRepository.findById(idUsuario);
        if (usuarioOpt.isEmpty()) {
            throw new RuntimeException("Usuário não encontrado");
        }

        List<Descarte> descartes = descarteRepository.findByUsuario(usuarioOpt.get());

        BigDecimal totalKg = BigDecimal.ZERO;
        BigDecimal totalCo2 = BigDecimal.ZERO;
        BigDecimal totalAgua = BigDecimal.ZERO;

        for (Descarte descarte : descartes) {

            for (DescarteItem item : descarte.getItens()) {

                BigDecimal quantidadeKg = item.getQuantidadeKg();
                totalKg = totalKg.add(quantidadeKg);

                Optional<FatoresMateriais> fatoresOpt = fatoresRepository.findById(
                        item.getMaterial().getIdMaterial()
                );

                if (fatoresOpt.isPresent()) {
                    FatoresMateriais fatores = fatoresOpt.get();

                    BigDecimal co2Evitado = quantidadeKg.multiply(fatores.getCo2eKgPorKg());
                    totalCo2 = totalCo2.add(co2Evitado);

                    BigDecimal aguaEconomizada = quantidadeKg.multiply(fatores.getAguaLitrosPorKg());
                    totalAgua = totalAgua.add(aguaEconomizada);
                }
            }
        }

        return new IndicadoresDTO(totalKg, totalCo2, totalAgua);
    }
}