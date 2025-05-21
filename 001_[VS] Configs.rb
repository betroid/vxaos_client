#==============================================================================
# ** Configs
#------------------------------------------------------------------------------
#  Este módulo lida com as configurações gerais. Ele também
# é executado no servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Configs
  
# Nome da fonte
  Font.default_name = 'Pixel UniCode'
  Font.default_bold = true #Fonte em Negrito. True = Sim - False = Não
  Font.default_italic = false #Fonte em Itálico. True = Sim - False = Não
  Font.default_shadow = true #Fonte com Sombra. True = Sim - False = Não
  Font.default_outline = false #Contorno na fonte. True = Sim - False = Não
  Font.default_out_color = Color.new(0, 0, 0) #Cor da borda da fonte.
  
  # Nome, esboço, sombra, negrito e tamanho da fonte da
  #janela do bate-papo
  CHAT_FONT_NAME = 'Pixel UniCode'
  CHAT_FONT_OUTLINE = false
  CHAT_FONT_SHADOW = true
  CHAT_FONT_BOLD = true
  CHAT_FONT_SIZE = 18
  
  # Tamanho da fonte
  Font.default_size = 18
  
  # Endereço da rede
  HOST = '127.0.0.1'
  
  # Porta da rede
  # Qualquer alteração na porta da rede deve ser repetida
  #no arquivo configs.ini do servidor
  PORT = 5000
  
  # Versão
  GAME_VERSION = 12983
  
  # Site da loja para comprar VIP
  SHOP_WEBSITE = 'www.aldeiarpg.com'
  
  # Resoluções
  # As dimensões máximas da tela no executável
  #sem DirectX é 640x480
  RESOLUTIONS = [
    {:width => 800, :height => 608},
    {:width => 1024, :height => 608},
    {:width => 1024, :height => 720}
  ]
  
  # Tempo (em segundos) do carregamento (0 = desativado)
  LOADING_TIME = 2
  
  # Imagens de fundo do carregamento que serão
  #escolhidas aleatoriamente
  LOADING_TITLES = ['Title1', 'Title2']
  
	# Quantidade mínima e máxima de caracteres
	MIN_CHARACTERS = 3
	MAX_CHARACTERS = 13
  
  # Nível mínimo para atacar e ser atacado por outros
  #jogadores em mapas PvP
  MIN_LEVEL_PVP = 2
  
	# Quantidade máxima de heróis por conta
	MAX_ACTORS = 3
  
	# Quantidade máxima de atalhos
	MAX_HOTBAR = 9
  
  # Quantidade máxima de classes na criação de personagem
  #para jogadores comuns
  MAX_DEFAULT_CLASSES = 5
  
  # Quantidade máxima de classes na criação de personagem
  #para VIPs
  MAX_VIP_CLASSES = 9
  
  # Quantidade máxima de itens, armas, protetores,
  #ouro, parâmetros e nível do jogador
  MAX_ITEMS  = 999
  MAX_GOLD   = 99_999_999
  MAX_PARAMS = 999_999
  MAX_LEVEL  = 99
  
	# Quantidade máxima de switches do jogador
  # Este valor deve ser definido antes do personagem ser criado
	MAX_PLAYER_SWITCHES = 100
  
	# Quantidade máxima de variáveis do jogador
  # Este valor deve ser definido antes do personagem ser criado
	MAX_PLAYER_VARIABLES = 100
  
  # Quantidade máxima de amigos
  MAX_FRIENDS = 20
  
  # Quantidade máxima de membros da guilda
  MAX_GUILD_MEMBERS = 50
  
  # Quantidade máxima de itens do inventário, da troca e do banco
  MAX_PLAYER_ITEMS = 30
  MAX_TRADE_ITEMS = 12
  MAX_BANK_ITEMS = 42
  
  # Quantidade máxima de linhas do bate-papo
  MAX_CHAT_LINES = 10 # Recomendável
  
  # Quantidade máxima de membros do grupo
  MAX_PARTY_MEMBERS = 4
  
  # Quantidade máxima de equipamentos
  # Este valor deve corresponder ao número de elementos da
  #matriz da ordem do gráfico dos equipamentos abaixo,
  #def equip_slots na [VS] Window_Equip e def draw_paperdolls
  #na [VS] Window_Base. Ele deve ser definido antes
  #do personagem ser criado
  MAX_EQUIPS = 9
  
  # Ordem do gráfico dos equipamentos
  # 0 = Arma, 1 = Escudo, 2 = Capacete, 3 = Armadura
  #4 = Acessório, 5 = Amuleto, 6 = Capa, 7 = Luva, 8 = Bota
  # Frente
  PAPERDOLL_DOWN_DIR = [3, 5, 2, 7, 6, 8, 1, 0, 4]
  # Esquerda
  PAPERDOLL_LEFT_DIR = [7, 0, 3, 5, 2, 6, 8, 1, 4]
  # Direita
  PAPERDOLL_RIGHT_DIR = [1, 3, 5, 2, 7, 6, 8, 0, 4]
  # Costas
  PAPERDOLL_UP_DIR = [7, 1, 0, 3, 5, 2, 8, 6, 4]
  
  # Índice da cor das mensagens do bate-papo na
  #Window.png da pasta System
  NORMAL_COLOR  = 0
  GLOBAL_COLOR  = 1
  SUCCESS_COLOR = 5
  ERROR_COLOR   = 10
  ALERT_COLOR   = 8
  ADM_MSG_COLOR = 17
  
  # Índice da cor do nome dos jogadores, inimigos e guildas
  #na Window.png da pasta System
  DEFAULT_COLOR = 0
  MONITOR_COLOR = 4
  ADMIN_COLOR   = 6
  ENEMY_COLOR   = 0
  BOSS_COLOR    = 10
  GUILD_COLOR   = 16
  
  # Índice no IconSet dos ícones do menu
  ITEM_ICON   = 260
  SKILL_ICON  = 96
  STATUS_ICON = 121
  QUEST_ICON  = 227
  FRIEND_ICON = 536
  GUILD_ICON  = 535
  MENU_ICON   = 117
  
  # Índice no IconSet dos ícones do menu de interação
  PRIVATE_ICON = 4
  BLOCK_ICON   = 538
  UNLOCK_ICON  = 539
  TRADE_ICON   = 540
  PARTY_ICON   = 12
  
  # Índice no IconSet dos demais ícones
  CONFIG_ICON            = 532
  GOLD_ICON              = 262
  EXP_ICON               = 125
  ADD_GOLD_ICON          = 528
  REMOVE_GOLD_ICON       = 529
  MAP_PVP_ICON           = 534
  MAP_NONPVP_ICON        = 533
  PLAYER_ON_ICON         = 189
  PLAYER_OFF_ICON        = 187
  QUEST_NOT_STARTED_ICON = 537
  QUEST_FINISHED_ICON    = 190
  QUEST_IN_PROGRESS_ICON = 189
  LEAVE_PARTY_ICON       = 530
  EMOJI_ICON             = 541
  
  # Índice no IconSet do início dos ícones de fortalecimento/buff
  ICON_BUFF_START = 64
  
  # Índice no IconSet do início dos ícones de enfraquecimento/debuff
  ICON_DEBUFF_START = 80
  
	# Quantidade de pontos iniciais na criação de personagem
	START_POINTS = 10
  
  # Altura de barra de título da janela
  TITLE_BAR_HEIGHT = 20
  
  # Teletransportes
  TELEPORTS = []
  TELEPORTS << [
    {:map_id => 1, :x => 21, :y => 12, :gold => 10},
    {:map_id => 2, :x => 4, :y => 20, :gold => 20}
  ]
  
  # Armas de longo alcance
  RANGE_WEAPONS = {}
  # Arma: Arco Curto (ID 31)
  RANGE_WEAPONS[31] = {
    # Gráfico
    :projectile_name => 'Arrow',
    # Alcance em tiles
    :range           => 10,
    # ID da munição (0 = infinito)
    :item_id         => 18
  }
  # Arma: Cajado de Madeira (ID 49)
  RANGE_WEAPONS[49] = {
    # Gráfico
    :projectile_name => 'Fire',
    # Alcance em tiles
    :range           => 10, 
    # ID da munição (0 = infinito)
    :item_id         => 0,
    # Animação (opcional)
    :step_anime      => false,
    # Custo de MP (opcional)
    :mp_cost         => 3
  }
  
  # Habilidades de longo alcance
  RANGE_SKILLS = {}
  # Habilidade: Fogo (ID 51)
  RANGE_SKILLS[51] = { :projectile_name => 'Fire' }
  # Habilidade: Luz das Estrelas (ID 70)
  RANGE_SKILLS[70] = {
    # Gráfico
    :projectile_name => 'Light',
    # Animação (opcional)
    :step_anime      => true
  }
  
  # Termos proibidos no nome dos jogadores comuns
  FORBIDDEN_NAMES = ['adm ', 'admin ', 'gm ', 'god ', 'mod ']
  
  # Emojis do bate-papo
  # Cada emoji deve ter 2 caracteres
  #CHAT_EMOJIS = [':P', '8)', ':v', '-)', ':o', ':(', ':@', '-(']
  
  # Tempo (em segundos) para o herói e inimigos atacarem novamente
  #O tempo mínimo para os inimigos é 0.8 (800 milissegundos)
	ATTACK_TIME = 0.8
  
  #LM² - Cooldown
	# Tempo (em segundos) padrão para a habilidade ser utilizada novamente
	COOLDOWN_SKILL_TIME = 1
  # Tempo (em segundos) para um item ser utilizado novamente
  COOLDOWN_ITEM_TIME = 1
  
  # Tempo (em segundos) para o jogador conversar novamente
  #no bate-papo global
  GLOBAL_ANTISPAM_TIME = 1
  
  # Tempo (em frames) da animação de ataque
  ATTACK_ANIMATION_TIME = 30
  
  # ID da animação que será executada ao subir nível
  LEVEL_UP_ANIMATION_ID = 40
  
  # Quantidade máxima de drops por mapa
  MAX_MAP_DROPS = 20
  
  # Tecla de ataque
  ATTACK_KEY = :LETTER_E
  
  # Andrart - Mouse Input Action
  MOUSE_ACTION_TIME = 1.0 
  
  # Tecla usada para pegar drop
  GET_DROP_KEY = :SPACE
  
  # Tecla usada para selecionar o inimigo mais próximo
  SELECT_ENEMY_KEY = :LETTER_Q
  
  # Teclas de atalho do menu
  ITEM_KEY   = :LETTER_C
  QUEST_KEY  = :LETTER_M
  FRIEND_KEY = :LETTER_F
  GUILD_KEY  = :LETTER_G
  MENU_KEY   = :ESCAPE
  
  # Teclas de atalho usadas para lançar habilidades/itens
  HOTKEYS = [:KEY_1, :KEY_2, :KEY_3, :KEY_4, :KEY_5, :KEY_6, :KEY_7, :KEY_8, :KEY_9]
  
  # Teclas usadas para exibir balões
  BALLOONS_KEYS = [:F3, :F4, :F5, :F6, :F7, :F8, :F9, :F10, :F11, :F12]
  
end
