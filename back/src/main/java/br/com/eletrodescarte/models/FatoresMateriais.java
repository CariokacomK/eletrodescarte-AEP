package br.com.eletrodescarte.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
@Table(name = "fatores_materiais")
public class FatoresMateriais {

    @Id
    @Column(name = "id_material")
    private Long idMaterial;

    @Column(name = "co2e_kg_por_kg", nullable = false, precision = 12, scale = 6)
    private BigDecimal co2eKgPorKg;

    @Column(name = "agua_litros_por_kg", nullable = false, precision = 12, scale = 2)
    private BigDecimal aguaLitrosPorKg;

    @Column(name = "indice_toxicidade_por_kg", nullable = false, precision = 12, scale = 6)
    private BigDecimal indiceToxicidadePorKg;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id_material")
    @JsonIgnore
    private Material material;
}