CREATE DATABASE IF NOT EXISTS `eletrodescarte`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `eletrodescarte`;

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome_completo` varchar(160) NOT NULL,
  `email` varchar(255) NOT NULL,
  `hash_senha` varchar(255) NOT NULL,
  `id_cidade` int(11) DEFAULT NULL,
  `papel` enum('cidadao','admin','moderador') NOT NULL DEFAULT 'cidadao',
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuarios_email` (`email`),
  KEY `idx_usuarios_cidade` (`id_cidade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `cidades`;
CREATE TABLE `cidades` (
  `id_cidade` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `uf` char(2) NOT NULL,
  `codigo_ibge` varchar(7) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_cidade`),
  UNIQUE KEY `uq_cidades_nome_uf` (`nome`,`uf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `usuarios`
ADD CONSTRAINT `fk_usuarios_cidade` FOREIGN KEY (`id_cidade`) REFERENCES `cidades` (`id_cidade`) ON DELETE SET NULL ON UPDATE CASCADE;

DROP TABLE IF EXISTS `auditoria`;
CREATE TABLE `auditoria` (
  `id_evento` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) DEFAULT NULL,
  `acao` varchar(80) NOT NULL,
  `detalhe` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detalhe`)),
  `ip` varchar(45) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_evento`),
  KEY `idx_aud_usuario_data` (`id_usuario`,`criado_em`),
  CONSTRAINT `fk_aud_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `conteudos_educativos`;
CREATE TABLE `conteudos_educativos` (
  `id_conteudo` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `corpo_md` mediumtext NOT NULL,
  `nivel` enum('basico','intermediario','avancado') NOT NULL DEFAULT 'basico',
  `publicado` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_conteudo`),
  UNIQUE KEY `uq_conteudos_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `organizacoes`;
CREATE TABLE `organizacoes` (
  `id_organizacao` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(160) NOT NULL,
  `tipo` enum('publica','privada','ong') NOT NULL,
  `site` varchar(255) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_organizacao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `pontos_coleta`;
CREATE TABLE `pontos_coleta` (
  `id_ponto` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(160) NOT NULL,
  `id_organizacao` int(11) NOT NULL,
  `id_cidade` int(11) NOT NULL,
  `endereco` varchar(255) NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `telefone` varchar(40) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_ponto`),
  UNIQUE KEY `uq_pontos_org_nome_cidade` (`id_organizacao`,`nome`,`id_cidade`),
  KEY `idx_pontos_cidade_ativos` (`id_cidade`,`ativo`),
  KEY `idx_pontos_geo` (`latitude`,`longitude`),
  CONSTRAINT `fk_pontos_cidade` FOREIGN KEY (`id_cidade`) REFERENCES `cidades` (`id_cidade`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pontos_org` FOREIGN KEY (`id_organizacao`) REFERENCES `organizacoes` (`id_organizacao`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `descartes`;
CREATE TABLE `descartes` (
  `id_descarte` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `id_ponto` int(11) NOT NULL,
  `descartado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id_descarte`),
  KEY `idx_descartes_usuario_data` (`id_usuario`,`descartado_em`),
  KEY `idx_descartes_ponto_data` (`id_ponto`,`descartado_em`),
  CONSTRAINT `fk_descartes_ponto` FOREIGN KEY (`id_ponto`) REFERENCES `pontos_coleta` (`id_ponto`) ON UPDATE CASCADE,
  CONSTRAINT `fk_descartes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `materiais`;
CREATE TABLE `materiais` (
  `id_material` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `descricao` text DEFAULT NULL,
  `unidade` varchar(10) NOT NULL DEFAULT 'kg',
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_material`),
  UNIQUE KEY `uq_materiais_nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `descarte_itens`;
CREATE TABLE `descarte_itens` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `id_descarte` int(11) NOT NULL,
  `id_material` int(11) NOT NULL,
  `quantidade_kg` decimal(12,3) NOT NULL,
  PRIMARY KEY (`id_item`),
  UNIQUE KEY `uq_item_unico` (`id_descarte`,`id_material`),
  KEY `idx_itens_material` (`id_material`),
  CONSTRAINT `fk_itens_descarte` FOREIGN KEY (`id_descarte`) REFERENCES `descartes` (`id_descarte`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_itens_material` FOREIGN KEY (`id_material`) REFERENCES `materiais` (`id_material`) ON UPDATE CASCADE,
  CONSTRAINT `chk_qtd_kg` CHECK (`quantidade_kg` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `fatores_materiais`;
CREATE TABLE `fatores_materiais` (
  `id_material` int(11) NOT NULL,
  `co2e_kg_por_kg` decimal(12,6) NOT NULL DEFAULT 0.000000,
  `agua_litros_por_kg` decimal(12,2) NOT NULL DEFAULT 0.00,
  `indice_toxicidade_por_kg` decimal(12,6) NOT NULL DEFAULT 0.000000,
  PRIMARY KEY (`id_material`),
  CONSTRAINT `fk_fatores_material` FOREIGN KEY (`id_material`) REFERENCES `materiais` (`id_material`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `horarios_funcionamento`;
CREATE TABLE `horarios_funcionamento` (
  `id_horario` int(11) NOT NULL AUTO_INCREMENT,
  `id_ponto` int(11) NOT NULL,
  `dia_semana` tinyint(3) unsigned NOT NULL,
  `abre_as` time NOT NULL,
  `fecha_as` time NOT NULL,
  PRIMARY KEY (`id_horario`),
  UNIQUE KEY `uq_horarios_ponto_dia` (`id_ponto`,`dia_semana`),
  CONSTRAINT `fk_horarios_ponto` FOREIGN KEY (`id_ponto`) REFERENCES `pontos_coleta` (`id_ponto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_dia_semana` CHECK (`dia_semana` between 0 and 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `pontos_materiais`;
CREATE TABLE `pontos_materiais` (
  `id_ponto` int(11) NOT NULL,
  `id_material` int(11) NOT NULL,
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id_ponto`,`id_material`),
  KEY `idx_pontos_materiais_mat` (`id_material`),
  CONSTRAINT `fk_pm_material` FOREIGN KEY (`id_material`) REFERENCES `materiais` (`id_material`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pm_ponto` FOREIGN KEY (`id_ponto`) REFERENCES `pontos_coleta` (`id_ponto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `sessoes`;
CREATE TABLE `sessoes` (
  `id_sessao` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `refresh_token` char(64) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `expira_em` datetime NOT NULL,
  `revogado` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_sessao`),
  UNIQUE KEY `uq_refresh` (`refresh_token`),
  KEY `idx_sessoes_usuario` (`id_usuario`,`revogado`),
  CONSTRAINT `fk_sessoes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `tentativas_login`;
CREATE TABLE `tentativas_login` (
  `id_tentativa` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `sucesso` tinyint(1) NOT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_tentativa`),
  KEY `idx_tentativas_email_data` (`email`,`criado_em`),
  KEY `idx_tentativas_sucesso` (`sucesso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO cidades (id_cidade, nome, uf, codigo_ibge) VALUES
(1, 'Maringá', 'PR', '4115200'),
(2, 'Curitiba', 'PR', '4106902'),
(3, 'São Paulo', 'SP', '3550308')
ON DUPLICATE KEY UPDATE nome=nome;

INSERT INTO organizacoes (id_organizacao, nome, tipo, site) VALUES
(1, 'Prefeitura de Maringá', 'publica', 'https://maringa.pr.gov.br'),
(2, 'Coleta Certa LTDA', 'privada', 'https://coletacerta.com'),
(3, 'ONG Recicla Tech', 'ong', 'https://reciclatech.org')
ON DUPLICATE KEY UPDATE nome=nome;

INSERT INTO materiais (id_material, nome, descricao, unidade) VALUES
(1, 'Pilhas e Baterias', 'Pilhas comuns, baterias de celular, notebook.', 'kg'),
(2, 'Celulares e Tablets', 'Aparelhos inteiros, mesmo quebrados.', 'un'),
(3, 'Computadores', 'Desktops, notebooks, CPUs, monitores.', 'un'),
(4, 'Lâmpadas Fluorescentes', 'Lâmpadas que contêm mercúrio.', 'un')
ON DUPLICATE KEY UPDATE nome=nome;

INSERT INTO pontos_coleta (id_ponto, nome, id_organizacao, id_cidade, endereco, latitude, longitude, telefone, email, ativo) VALUES
(1, 'Paço Municipal de Maringá', 1, 1, 'Av. XV de Novembro, 701 - Zona 01, Maringá - PR', -23.4253, -51.9386, '(44) 3221-1234', 'coleta@maringa.pr.gov.br', 1),
(2, 'Loja Coleta Certa - Centro SP', 2, 3, 'Rua Augusta, 1500 - Consolação, São Paulo - SP', -23.5558, -46.6620, '(11) 98765-4321', 'contato@coletacerta.com', 1),
(3, 'Sede ONG Recicla Tech', 3, 2, 'Av. Sete de Setembro, 2000 - Centro, Curitiba - PR', -25.4338, -49.2730, '(41) 91234-5678', 'ajuda@reciclatech.org', 1)
ON DUPLICATE KEY UPDATE nome=nome;

INSERT INTO horarios_funcionamento (id_ponto, dia_semana, abre_as, fecha_as) VALUES
(1, 1, '08:00:00', '17:00:00'), 
(1, 2, '08:00:00', '17:00:00'), 
(1, 3, '08:00:00', '17:00:00'),
(1, 4, '08:00:00', '17:00:00'),
(1, 5, '08:00:00', '17:00:00'),
(2, 1, '09:00:00', '18:00:00'), 
(2, 2, '09:00:00', '18:00:00'),
(2, 3, '09:00:00', '18:00:00'),
(2, 4, '09:00:00', '18:00:00'),
(2, 5, '09:00:00', '18:00:00'),
(3, 2, '13:00:00', '17:00:00'),
(3, 4, '13:00:00', '17:00:00')
ON DUPLICATE KEY UPDATE abre_as=abre_as;

INSERT INTO pontos_materiais (id_ponto, id_material) VALUES
(1, 1),
(1, 2),
(1, 4),
(2, 1),
(2, 2),
(2, 3),
(3, 1),
(3, 2),
(3, 3),
(3, 4)
ON DUPLICATE KEY UPDATE id_ponto=id_ponto;

INSERT INTO conteudos_educativos (id_conteudo, titulo, slug, corpo_md, nivel, publicado) VALUES
(1, 'O que é E-Lixo?', 'o-que-e-e-lixo', 'O lixo eletrônico, ou e-lixo, é todo resíduo de equipamentos elétricos e eletrônicos. Isso inclui desde pilhas até geladeiras. O descarte incorreto é perigoso...', 'basico', 1),
(2, 'O Perigo do Mercúrio em Lâmpadas', 'perigo-mercurio-lampadas', 'Lâmpadas fluorescentes contêm mercúrio, um metal pesado altamente tóxico. Quando descartadas no lixo comum, elas podem quebrar e contaminar o solo...', 'intermediario', 1),
(3, 'Como Reciclar Placas de Computador', 'reciclar-placas-pc', 'Placas-mãe e outros circuitos impressos são ricos em metais preciosos como ouro, prata e paládio. O processo de extração é complexo...', 'avancado', 1)
ON DUPLICATE KEY UPDATE titulo=titulo;

INSERT INTO fatores_materiais (id_material, co2e_kg_por_kg, agua_litros_por_kg, indice_toxicidade_por_kg) VALUES
(1, 4.5, 50.0, 0.85), 
(2, 12.0, 250.0, 0.60),
(3, 8.0, 150.0, 0.40), 
(4, 2.0, 10.0, 1.50)
ON DUPLICATE KEY UPDATE co2e_kg_por_kg=co2e_kg_por_kg;

INSERT INTO usuarios (id_usuario, nome_completo, email, hash_senha, id_cidade, papel) VALUES
(100, 'Cidadão Exemplo', 'cidadao@exemplo.com', '$2a$10$/0EuLtD5/SGKA.Wc9coyyudUmz.f9Q920XwQs2lwYdmcqVLZBNekK', 1, 'CIDADAO')
ON DUPLICATE KEY UPDATE nome_completo=nome_completo;

INSERT INTO descartes (id_descarte, id_usuario, id_ponto, descartado_em) VALUES
(100, 100, 1, '2025-10-01 10:00:00')
ON DUPLICATE KEY UPDATE id_usuario=id_usuario;


INSERT INTO descarte_itens (id_item, id_descarte, id_material, quantidade_kg) VALUES
(100, 100, 1, 2.5),
(101, 100, 3, 10.0)
ON DUPLICATE KEY UPDATE quantidade_kg=quantidade_kg;