#==============================================================================
# ** Configurations
#------------------------------------------------------------------------------
#  Configurações de personalização para a janela de criação de personagem.
#  Autor: Valentine                          Mod: Merim
#==============================================================================

module Configurations
  TEXT_COLOR = Color.new(125, 100,78)          # Cor do texto
  INFO_COLOR = Color.new(255, 100, 0)          # Cor das informações
  FONT_SIZE = 15                               # Tamanho da fonte
end
#==============================================================================
#==============================================================================
# ** Window_CreateChar
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de criação de personagem.
#------------------------------------------------------------------------------
#==============================================================================
class Window_CreateChar < Window_Base
  def initialize
    super(adjust_x, adjust_y, 431, 288) # Aumenta a largura da janela
    self.visible = false
    self.closable = true
    self.title = Vocab::NewChar
    self.contents.font.size = Configurations::FONT_SIZE
    create_buttons
  end

  def adjust_x
    Graphics.width / 2 - 215  # Ajuste para a nova largura da janela
  end

  def adjust_y
    Graphics.height / 2 - 154
  end

  def max_classes
    $network.vip? ? Configs::MAX_VIP_CLASSES : Configs::MAX_DEFAULT_CLASSES
  end

  def class_names
    (1..max_classes).collect { |class_id| $data_classes[class_id].name }
  end

  def create_buttons
    @name_box = Text_Box.new(self, 79, 20, 115, Configs::MAX_CHARACTERS) { enable_create_button }
    @next_class = Image_Button.new(self, 412, 20, 'Right') { next_class } # Aumenta o espaçamento
    @prev_class = Image_Button.new(self, 260, 20, 'Left') { prev_class }  # Aumenta o espaçamento
    @next_sex = Image_Button.new(self, 176, 48, 'Right') { change_sex(Enums::Sex::FEMALE) }
    @prev_sex = Image_Button.new(self, 79, 48, 'Left') { change_sex(Enums::Sex::MALE) }
    @next_char = Image_Button.new(self, 176, 75, 'Right') { next_character }
    @prev_char = Image_Button.new(self, 79, 75, 'Left') { prev_character }
    @rem_hp = Button.new(self, 19, 147, '-', 26) { remove_param(0) }
    @rem_mp = Button.new(self, 19, 171, '-', 26) { remove_param(1) }
    @rem_atk = Button.new(self, 19, 195, '-', 26) { remove_param(2) }
    @rem_agi = Button.new(self, 19, 219, '-', 26) { remove_param(3) }
    @add_hp = Button.new(self, 166, 147, '+', 26) { add_param(0) }
    @add_mp = Button.new(self, 166, 171, '+', 26) { add_param(1) }
    @add_atk = Button.new(self, 166, 195, '+', 26) { add_param(2) }
    @add_agi = Button.new(self, 166, 219, '+', 26) { add_param(3) }
    @rem_def = Button.new(self, 211, 147, '-', 26) { remove_param(4) }
    @rem_mat = Button.new(self, 211, 171, '-', 26) { remove_param(5) }
    @rem_mdf = Button.new(self, 211, 195, '-', 26) { remove_param(6) }
    @rem_luk = Button.new(self, 211, 219, '-', 26) { remove_param(7) }
    @add_def = Button.new(self, 366, 147, '+', 26) { add_param(4) }
    @add_mat = Button.new(self, 366, 171, '+', 26) { add_param(5) }
    @add_mdf = Button.new(self, 366, 195, '+', 26) { add_param(6) }
    @add_luk = Button.new(self, 366, 219, '+', 26) { add_param(7) }
    @create_button = Button.new(self, 168, 254, Vocab::Create, 64) { create_actor }
    @points_bar = Progress_Bar.new(self, 18, 121, 375, Configs::START_POINTS) if Configs::START_POINTS > 0
  end
  def show(actor_id)
    @actor_id = actor_id
    @sex = Enums::Sex::MALE
    @points = Configs::START_POINTS
    @class_id = 1
    @sprite_index = 0
    refresh_character
    @params = Array.new(8, 0)
    @name_box.clear
    @create_button.enable = false
    super()
    @name_box.active = true
    enable_buttons
  end

  def hide
    super
    SceneManager.scene.change_background('Title2')
    $windows[:alert].hide
    $windows[:use_char].show
  end

  def invalid_name?
    @name_box.text =~ /[^A-Za-z0-9 ]/
  end

  def illegal_name?
    Configs::FORBIDDEN_NAMES.any? { |word| @name_box.text =~ /#{word}/i }
  end

  def refresh
    contents.clear
    draw_shadow(100, 80)
    draw_character(@character_name, @character_index, 124, 103)
    change_color(Configurations::TEXT_COLOR)
    draw_text(4, 8, 45, line_height, "#{Vocab::Name}:")
    draw_text(185, 8, 60, line_height, Vocab::Class) # Ajustado para mais à frente
    draw_text(280, 8, 100, line_height, $data_classes[@class_id].name, 1) # Centralizado entre as setas
    draw_text(4, 35, 45, line_height, Vocab::Sex)
    draw_text(97, 35, 55, line_height, @sex == Enums::Sex::MALE ? Vocab::Male : Vocab::Female, 1)
    draw_text(4, 62, 70, line_height, Vocab::Graphic)
    change_color(Configurations::INFO_COLOR)
    draw_text(119, 137, 25, line_height, @params[0] * 10 + $data_classes[@class_id].params[0, 1], 2)
    draw_text(119, 161, 25, line_height, @params[1] * 10 + $data_classes[@class_id].params[1, 1], 2)
    draw_justified_texts(196, 31, 225, line_height, $data_actors[@class_id].description.delete("\n"))
    (2...8).each do |param_id|
      draw_text(param_id / 4 * 189 + 119, param_id % 4 * 24 + 137, 25, line_height, $data_classes[@class_id].params[param_id, 1] + @params[param_id], 2)
    end
    change_color(system_color)
    (0...8).each do |param_id|
      draw_text(param_id / 4 * 193 + 47, param_id % 4 * 24 + 137, 100, line_height, "#{Vocab::param(param_id)}:")
    end
    if @points_bar
      @points_bar.index = @points
      @points_bar.text = "#{@points}/#{Configs::START_POINTS}"
    end
    @next_char.visible = @prev_char.visible = $data_classes[@class_id].graphics[@sex].size > 1
  end

  def refresh_character
    @character_name = $data_classes[@class_id].graphics[@sex][@sprite_index][0]
    @character_index = $data_classes[@class_id].graphics[@sex][@sprite_index][1]
  end

  def create_actor
    return unless @create_button.enable
    if illegal_name? && $network.standard_group?
      $windows[:alert].show(Vocab::InvalidName)
    elsif invalid_name?
      $windows[:alert].show(Vocab::ForbiddenCharacter)
    else
      $network.send_create_actor(@actor_id, @name_box.text, @sprite_index, @class_id, @sex, @params)
    end
  end

  def change_sex(sex)
    @sex = sex
    @sprite_index = 0
    refresh_character
    refresh
  end

  def next_class
    @class_id = @class_id < max_classes ? @class_id + 1 : 1
    refresh_character
    refresh
  end

  def prev_class
    @class_id = @class_id > 1 ? @class_id - 1 : max_classes
    refresh_character
    refresh
  end

  def next_character
    @sprite_index = @sprite_index < $data_classes[@class_id].graphics[@sex].size - 1 ? @sprite_index + 1 : 0
    refresh_character
    refresh
  end

  def prev_character
    @sprite_index = @sprite_index > 0 ? @sprite_index - 1 : $data_classes[@class_id].graphics[@sex].size - 1
    refresh_character
    refresh
  end

  def add_param(param_id)
    @points -= 1
    @params[param_id] += 1
    refresh
    enable_buttons
  end

  def remove_param(param_id)
    @points += 1
    @params[param_id] -= 1
    refresh
    enable_buttons
  end

  def enable_buttons
    @rem_hp.enable = @params[0] > 0
    @rem_mp.enable = @params[1] > 0
    @rem_atk.enable = @params[2] > 0
    @rem_agi.enable = @params[3] > 0
    @rem_def.enable = @params[4] > 0
    @rem_mat.enable = @params[5] > 0
    @rem_mdf.enable = @params[6] > 0
    @rem_luk.enable = @params[7] > 0
    enable = @points > 0
    @add_hp.enable = enable
    @add_mp.enable = enable
    @add_atk.enable = enable
    @add_agi.enable = enable
    @add_def.enable = enable
    @add_mat.enable = enable
    @add_mdf.enable = enable
    @add_luk.enable = enable
  end

  def enable_create_button
    @create_button.enable = @name_box.text.strip.size >= Configs::MIN_CHARACTERS
  end

  def update
    super
    close_windows
    ok if Input.trigger?(:C)
  end

  def close_windows
    return unless Input.trigger?(:B)
    if $windows[:alert].visible || $windows[:config].visible
      $windows[:alert].hide
      $windows[:config].hide
    else
      hide
    end
  end

  def ok
    $windows[:alert].visible ? $windows[:alert].hide : create_actor
  end
end