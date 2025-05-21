#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de habilidades.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class RPG::Skill < RPG::UsableItem
  def required_level
    learning = $data_classes[$game_actors[1].class_id].learnings.find { |learn| learn.skill_id == self.id }
    learning ? learning.level : 0
  end
end

class Window_Skill < Window_ItemSelectable
  
  def initialize
    super(adjust_x, adjust_y, 212, 323)
    @dragable = false
    self.visible = false
    self.title = Vocab::skill
  end

  def adjust_x
    $windows[:equip].x
  end
  
  def adjust_y
    $windows[:equip].y
  end 
  
  def enable?(item)
    $game_actors[1].usable?(item) && $game_actors[1].level >= item.required_level
  end

  def make_item_list
    @data = $data_classes[$game_actors[1].class_id].learnings.collect do |learning|
    $data_skills[learning.skill_id] if $data_skills[learning.skill_id] && $game_actors[1].added_skill_types.include?($data_skills[learning.skill_id].stype_id)
    end.compact
  end

  def refresh
    make_item_list
    create_contents
    draw_all_items
  end

  def update
    super
    disable_attack_while_open
    @scroll_bar.update if active
    update_scroll if active
  end

  def update_scroll
    if Input.wheel_up?
      self.oy -= 10
    elsif Input.wheel_down?
      self.oy += 10
    end
    self.oy = [[self.oy, 0].max, [contents_height - height, 0].max].min
  end

  def update_drag
    return unless Mouse.press?(:L)
    return if $cursor.object
    return if $dragging_window
    return unless index >= 0
    return unless enable?(item)
    $cursor.change_item(item, Enums::Mouse::SKILL)
  end

  def draw_item(index)
    skill = @data[index]
    return unless skill
    rect = item_rect(index)
    
    #Informações
    draw_text(50, 216, contents_width, line_height, 'Informações:')
    
    #Linhas decorativas
    self.contents.fill_rect(25, 244, contents_width - 50, 1, Color.new(80, 80, 80))  # Linha superior
    self.contents.fill_rect(25, 276, contents_width - 50, 1, Color.new(80, 80, 80))  # Linha inferior
    
    change_color(text_color(17))
    draw_text(25, 242, contents_width, line_height, 'Arraste as habilidades')
    draw_text(25, 254, contents_width, line_height, 'para os atalhos abaixo')
    
    change_color(normal_color)

    #Ajustar fundo para um cinza escuro moderado
    background_color = Color.new(40, 40, 40)
    contents.fill_rect(rect, background_color)

    if index == self.index
      # Seleção cinza claro ao passar o mouse
      selection_color = Color.new(200, 200, 200)
      contents.fill_rect(rect, selection_color)
    end

    icon_bitmap = Cache.system("Iconset")
    icon_index = skill.icon_index
    rect_icon = Rect.new((icon_index % 16) * 24, (icon_index / 16) * 24, 24, 24)

    opacity = $game_actors[1].level >= skill.required_level ? 255 : 128

    contents.blt(rect.x + 1, rect.y + 8, icon_bitmap, rect_icon, opacity)
    draw_text(rect.x + 30, rect.y + 8, rect.width - 34, line_height, skill.name)
    
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = (width - standard_padding * 1 - 32) / 1  # Ajuste a largura para diminuir o tamanho das skills e centralizar
    rect.height = line_height * 1 + 1
    rect.x = standard_padding + (index % 1) * (rect.width + 32)  # Ajuste o espaçamento horizontal para centralizar e criar espaço nas laterais
    rect.y = (index / 1) * (rect.height + 8) + 1
    rect
  end

  #def contents_height
    #((@data.size + 1) / 1) * (line_height * 1 + 8) + 30  # Ajuste para garantir que os últimos 30 pixels sejam visíveis
  #end

  def disable_attack_while_open
    if active
      $game_player.instance_variable_set(:@disable_attack, true)
    end
  end

  def deactivate
    super
    $game_player.instance_variable_set(:@disable_attack, false)
  end
end

class Game_Player < Game_Character
  alias original_update update
  def update
    if SceneManager.scene_is?(Scene_Map) && SceneManager.scene.skill_window_active?
      return if Input.trigger?(Configs::ATTACK_KEY)
    end
    original_update
  end
end

class Scene_Map < Scene_Base
  attr_reader :skill_window

  def create_all_windows
    super
    create_skill_window
  end

  def create_skill_window
    @skill_window = Window_Skill.new(0, 0, Graphics.width, Graphics.height)
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
  end

  def skill_window_active?
    @skill_window && @skill_window.active
  end

  def on_skill_cancel
    @skill_window.close
    @skill_window.deactivate
  end
  
end