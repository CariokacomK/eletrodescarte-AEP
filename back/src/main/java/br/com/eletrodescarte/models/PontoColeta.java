package br.com.eletrodescarte.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
@Table(name = "pontos_coleta")
public class PontoColeta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ponto")
    private Long idPonto;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false)
    private String endereco;

    private Double latitude;
    private Double longitude;
    private String telefone;
    private String email;
    private boolean ativo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_organizacao", nullable = false)
    private Organizacao organizacao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_cidade", nullable = false)
    private Cidade cidade;

    @OneToMany(mappedBy = "pontoColeta", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<HorarioFuncionamento> horarios;

    @ManyToMany
    @JoinTable(
            name = "pontos_materiais",
            joinColumns = @JoinColumn(name = "id_ponto"),
            inverseJoinColumns = @JoinColumn(name = "id_material")
    )
    private Set<Material> materiaisAceitos = new HashSet<>();

    @OneToMany(mappedBy = "pontoColeta")
    @JsonIgnore
    private List<Descarte> descartes;
}