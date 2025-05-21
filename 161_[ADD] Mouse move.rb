#==============================================================================
# Movimentação por Clique + Indicador Visual (32x32)
# Compatível com Mouse.rb e sistema online de Valentine (VXA-OS)
# Requer imagem "Clique.png" em Graphics/System
#==============================================================================

class Game_Player < Game_Character
  MOVE_INTERVAL = 1        # Responsividade de cliques (frames)
  MOVE_THRESHOLD = 0.5     # Distância mínima para considerar novo destino

  alias init_mouse_move initialize
  def initialize
    init_mouse_move
    @path_queue = []
    @click_cooldown = 0
    @last_indicator_pos = nil
    @indicator_cooldown = 0
    @last_mouse_pressed = false
  end

  alias update_mouse_move update
  def update
    update_mouse_move
    update_mouse_click unless $game_map.interpreter.running?
    @click_cooldown -= 1 if @click_cooldown > 0
    @indicator_cooldown -= 1 if @indicator_cooldown > 0
  end

  def update_mouse_click
    return unless movable?
    return if $wait_player_move || $typing
    return if @click_cooldown > 0
    return if over_blocking_window?

    mouse_pressed = Mouse.press?(:L)

    # Detecta clique novo (borda de pressão)
    if mouse_pressed && !@last_mouse_pressed
      target_x = Mouse.tile_x
      target_y = Mouse.tile_y
      return unless $game_map.valid?(target_x, target_y)

      dx = (target_x - @x).abs
      dy = (target_y - @y).abs
      return if dx < MOVE_THRESHOLD && dy < MOVE_THRESHOLD

      path = find_path(@x, @y, target_x, target_y)
      if path && !path.empty?
        # Exibe indicador visual de clique
        if @last_indicator_pos != [target_x, target_y] || @indicator_cooldown <= 0
          spriteset = SceneManager.scene.instance_variable_get(:@spriteset)
          spriteset.show_click_indicator(target_x, target_y) if spriteset
          @last_indicator_pos = [target_x, target_y]
          @indicator_cooldown = 10
        end

        @path_queue = path
        @move_speed = 4
        first_step = @path_queue.first
        set_direction(direction_to(@x, @y, first_step[0], first_step[1])) if first_step
        @click_cooldown = 10
      else
        # Se não há caminho, apenas vira na direção clicada
        set_direction(direction_to(@x, @y, target_x, target_y))
        @path_queue.clear
      end
    end

    @last_mouse_pressed = mouse_pressed

    move_along_path
  end

  def move_along_path
    return if @path_queue.empty?

    next_pos = @path_queue.first
    dir = direction_to(@x, @y, next_pos[0], next_pos[1])

    if passable?(@x, @y, dir)
      move_straight(dir)
      $network.send_player_movement(dir) if $network rescue nil
      $wait_player_move = true
      @path_queue.shift

      # Quando termina a rota, envia posição real para o servidor
      if @path_queue.empty?
        $network.send_player_position(@x, @y) if $network rescue nil
      end
    else
      # Interrompe rota se for bloqueada
      @path_queue.clear
    end
  end

  def direction_to(x1, y1, x2, y2)
    return 2 if y2 > y1
    return 4 if x2 < x1
    return 6 if x2 > x1
    return 8 if y2 < y1
    0
  end

  # Algoritmo A* simplificado
  def find_path(start_x, start_y, goal_x, goal_y)
    open = [[start_x, start_y]]
    came_from = {}
    cost_so_far = {}
    came_from[[start_x, start_y]] = nil
    cost_so_far[[start_x, start_y]] = 0

    while !open.empty?
      current = open.shift
      break if current == [goal_x, goal_y]

      neighbors(current[0], current[1]).each do |next_tile|
        new_cost = cost_so_far[current] + 1
        if !cost_so_far.include?(next_tile) || new_cost < cost_so_far[next_tile]
          cost_so_far[next_tile] = new_cost
          open.push(next_tile)
          open.sort_by! { |pos| cost_so_far[pos] + heuristic(goal_x, goal_y, pos[0], pos[1]) }
          came_from[next_tile] = current
        end
      end
    end

    return nil unless came_from[[goal_x, goal_y]]

    path = []
    current = [goal_x, goal_y]
    while current != [start_x, start_y]
      path.unshift(current)
      current = came_from[current]
    end
    path
  end

  def neighbors(x, y)
    [[x, y-1], [x, y+1], [x-1, y], [x+1, y]].select do |nx, ny|
      $game_map.valid?(nx, ny) && passable?(x, y, direction_to(x, y, nx, ny))
    end
  end

  def heuristic(x1, y1, x2, y2)
    (x1 - x2).abs + (y1 - y2).abs
  end

  def over_blocking_window?
    return false unless defined?($windows)
    $windows.each_value do |window|
      next unless window.visible
      next if window.is_a?(Window_Chat) && !window.message_box_active?
      if window.x <= Mouse.x && Mouse.x <= window.x + window.width &&
         window.y <= Mouse.y && Mouse.y <= window.y + window.height
        return true
      end
    end
    false
  end
end

#==============================================================================
# Indicador Visual de Clique (32x32)
#==============================================================================

class Sprite_ClickIndicator < Sprite
  DURATION = 30

  def initialize(viewport, tile_x, tile_y)
    super(viewport)
    self.bitmap = Cache.system("Clique")
    self.z = 90
    @tile_x = tile_x
    @tile_y = tile_y
    @duration = DURATION
    update_position
  end

  def update
    super
    @duration -= 1
    update_position
    dispose if @duration <= 0
  end

  def update_position
    self.x = (@tile_x * 32) - ($game_map.display_x * 32).to_i
    self.y = (@tile_y * 32) - ($game_map.display_y * 32).to_i
  end
end

#==============================================================================
# Controle dos Efeitos de Clique no Spriteset_Map
#==============================================================================

class Spriteset_Map
  alias init_click_fx initialize
  alias update_click_fx update
  alias dispose_click_fx dispose

  def initialize
    @click_indicators = []
    init_click_fx
  end

  def update
    update_click_fx
    update_click_indicators
  end

  def dispose
    dispose_click_indicators
    dispose_click_fx
  end

  def update_click_indicators
    @click_indicators.each(&:update)
    @click_indicators.reject!(&:disposed?)
  end

  def dispose_click_indicators
    @click_indicators.each(&:dispose)
    @click_indicators.clear
  end

  def show_click_indicator(tile_x, tile_y)
    @click_indicators << Sprite_ClickIndicator.new(@viewport1, tile_x, tile_y)
  end
end

#==============================================================================
# Compatibilidade com a Janela de Chat do Valentine
#==============================================================================

class Window_Chat
  def message_box_active?
    @message_box && @message_box.active
  end
end

#==============================================================================
# Suporte adicional ao módulo Mouse (Valentine)
#==============================================================================

module Mouse
  def self.in?(window)
    Mouse.x.between?(window.x, window.x + window.width) &&
    Mouse.y.between?(window.y, window.y + window.height)
  end
end