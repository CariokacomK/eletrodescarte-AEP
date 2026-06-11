package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.repositories.*;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DescarteServiceTest {

    @Mock
    private DescarteRepository descarteRepository;

    @Mock
    private UsuarioRepository usuarioRepository;

    @Mock
    private PontoColetaRepository pontoColetaRepository;

    @Mock
    private MaterialRepository materialRepository;

    @Mock
    private FatoresMateriaisRepository fatoresRepository;

    @InjectMocks
    private DescarteService descarteService;

    @Test
    void registrarDescarte_ComSucesso() {
        // Arrange
        Long idUsuario = 1L;
        Long idPonto = 1L;
        Long idMaterial = 1L;
        BigDecimal quantidade = new BigDecimal("10.0");

        Usuario usuario = new Usuario();
        usuario.setIdUsuario(idUsuario);

        PontoColeta ponto = new PontoColeta();
        ponto.setIdPonto(idPonto);

        Material material = new Material();
        material.setIdMaterial(idMaterial);

        FatoresMateriais fatores = new FatoresMateriais();
        fatores.setIdMaterial(idMaterial);
        fatores.setCo2eKgPorKg(new BigDecimal("2.5"));
        fatores.setAguaLitrosPorKg(new BigDecimal("50.0"));

        Descarte descarteSalvo = new Descarte();
        descarteSalvo.setIdDescarte(100L);

        DescarteService.ItemDescarteDTO itemDTO = new DescarteService.ItemDescarteDTO(idMaterial, quantidade);
        DescarteService.NovoDescarteRequestDTO request = new DescarteService.NovoDescarteRequestDTO(
                idUsuario, idPonto, "Observação", Collections.singletonList(itemDTO)
        );

        when(usuarioRepository.findById(idUsuario)).thenReturn(Optional.of(usuario));
        when(pontoColetaRepository.findById(idPonto)).thenReturn(Optional.of(ponto));
        when(materialRepository.findById(idMaterial)).thenReturn(Optional.of(material));
        when(fatoresRepository.findById(idMaterial)).thenReturn(Optional.of(fatores));
        when(descarteRepository.save(any(Descarte.class))).thenReturn(descarteSalvo);

        // Act
        DescarteService.SimulacaoImpactoDTO result = descarteService.registrarDescarte(request);

        // Assert
        assertNotNull(result);
        assertEquals(100L, result.idDescarte());
        assertEquals(new BigDecimal("10.0"), result.totalKg());
        assertEquals(new BigDecimal("25.00"), result.co2Evitado()); // 10 * 2.5
        assertEquals(new BigDecimal("500.00"), result.aguaEconomizada()); // 10 * 50
        verify(descarteRepository, times(1)).save(any(Descarte.class));
    }

    @Test
    void registrarDescarte_ErroPesoNegativo() {
        // Arrange
        Long idUsuario = 1L;
        Long idPonto = 1L;
        Long idMaterial = 1L;
        BigDecimal quantidadeNegativa = new BigDecimal("-5.0");

        Usuario usuario = new Usuario();
        usuario.setIdUsuario(idUsuario);

        PontoColeta ponto = new PontoColeta();
        ponto.setIdPonto(idPonto);

        DescarteService.ItemDescarteDTO itemDTO = new DescarteService.ItemDescarteDTO(idMaterial, quantidadeNegativa);
        DescarteService.NovoDescarteRequestDTO request = new DescarteService.NovoDescarteRequestDTO(
                idUsuario, idPonto, "Observação", Collections.singletonList(itemDTO)
        );

        when(usuarioRepository.findById(idUsuario)).thenReturn(Optional.of(usuario));
        when(pontoColetaRepository.findById(idPonto)).thenReturn(Optional.of(ponto));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            descarteService.registrarDescarte(request);
        });

        assertEquals("A quantidade em Kg deve ser maior que zero.", exception.getMessage());
        verify(descarteRepository, never()).save(any(Descarte.class));
    }

    @Test
    void registrarDescarte_ErroPesoZero() {
        // Arrange
        Long idUsuario = 1L;
        Long idPonto = 1L;
        Long idMaterial = 1L;
        BigDecimal quantidadeZero = BigDecimal.ZERO;

        Usuario usuario = new Usuario();
        usuario.setIdUsuario(idUsuario);

        PontoColeta ponto = new PontoColeta();
        ponto.setIdPonto(idPonto);

        DescarteService.ItemDescarteDTO itemDTO = new DescarteService.ItemDescarteDTO(idMaterial, quantidadeZero);
        DescarteService.NovoDescarteRequestDTO request = new DescarteService.NovoDescarteRequestDTO(
                idUsuario, idPonto, "Observação", Collections.singletonList(itemDTO)
        );

        when(usuarioRepository.findById(idUsuario)).thenReturn(Optional.of(usuario));
        when(pontoColetaRepository.findById(idPonto)).thenReturn(Optional.of(ponto));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            descarteService.registrarDescarte(request);
        });

        assertEquals("A quantidade em Kg deve ser maior que zero.", exception.getMessage());
        verify(descarteRepository, never()).save(any(Descarte.class));
    }
}
