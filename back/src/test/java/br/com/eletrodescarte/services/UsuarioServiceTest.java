package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UsuarioServiceTest {

    @Mock
    private UsuarioRepository usuarioRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UsuarioService usuarioService;

    @Test
    void cadastrarUsuario_ComSucesso() {
        Usuario usuario = new Usuario();
        usuario.setEmail("test@example.com");
        usuario.setHashSenha("senha123");

        when(usuarioRepository.findByEmail("test@example.com")).thenReturn(Optional.empty());
        when(passwordEncoder.encode("senha123")).thenReturn("senhaCripto");
        when(usuarioRepository.save(any(Usuario.class))).thenReturn(usuario);

        Usuario resultado = usuarioService.cadastrarUsuario(usuario);

        assertNotNull(resultado);
        assertEquals("senhaCripto", usuario.getHashSenha());
        verify(usuarioRepository, times(1)).save(usuario);
    }

    @Test
    void cadastrarUsuario_ErroEmailDuplicado() {
        Usuario usuarioExistente = new Usuario();
        usuarioExistente.setEmail("duplicado@example.com");

        Usuario usuarioNovo = new Usuario();
        usuarioNovo.setEmail("duplicado@example.com");
        usuarioNovo.setHashSenha("senha123");

        when(usuarioRepository.findByEmail("duplicado@example.com")).thenReturn(Optional.of(usuarioExistente));

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            usuarioService.cadastrarUsuario(usuarioNovo);
        });

        assertEquals("E-mail já cadastrado.", exception.getMessage());
        verify(usuarioRepository, never()).save(any(Usuario.class));
    }
}
