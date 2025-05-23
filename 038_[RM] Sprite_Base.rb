#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  Uma classe de sprites com processo de exibição de animação adicionado.
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Variáveis de classe
  #--------------------------------------------------------------------------
  @@ani_checker = []
  @@ani_spr_checker = []
  @@_reference_count = {}
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     viewport  : camada
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @use_sprite = true        # Flag de uso de sprites
    @ani_duration = 0         # Tempo restante de animação
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_animation
    @@ani_checker.clear
    @@ani_spr_checker.clear
  end
  #--------------------------------------------------------------------------
  # * Definição de exibição de animação
  #--------------------------------------------------------------------------
  def animation?
    @animation != nil
  end
  #--------------------------------------------------------------------------
  # * Início da animação
  #     animation : informações da animação
  #     mirror    : flag de inversão dos sprites
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    if @animation
      @ani_mirror = mirror
      set_animation_rate
      @ani_duration = @animation.frame_max * @ani_rate + 1
      load_animation_bitmap
      make_animation_sprites
      set_animation_origin
    end
  end
  #--------------------------------------------------------------------------
  # * Definir velocidade da animação
  #--------------------------------------------------------------------------
  def set_animation_rate
    @ani_rate = 4     # Por padrão, valor fixo
  end
  #--------------------------------------------------------------------------
  # * Carregamento dos gráficos da animação
  #--------------------------------------------------------------------------
  def load_animation_bitmap
    animation1_name = @animation.animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = @animation.animation2_name
    animation2_hue = @animation.animation2_hue
    @ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@ani_bitmap1)
      @@_reference_count[@ani_bitmap1] += 1
    else
      @@_reference_count[@ani_bitmap1] = 1
    end
    if @@_reference_count.include?(@ani_bitmap2)
      @@_reference_count[@ani_bitmap2] += 1
    else
      @@_reference_count[@ani_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # * Criação dos sprites da animação
  #--------------------------------------------------------------------------
  def make_animation_sprites
    @ani_sprites = []
    if @use_sprite && !@@ani_spr_checker.include?(@animation)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @ani_sprites.push(sprite)
      end
      if @animation.position == 3
        @@ani_spr_checker.push(@animation)
      end
    end
    @ani_duplicated = @@ani_checker.include?(@animation)
    if !@ani_duplicated && @animation.position == 3
      @@ani_checker.push(@animation)
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de origem de criação da animação
  #--------------------------------------------------------------------------
  def set_animation_origin
    if @animation.position == 3
      if viewport == nil
        @ani_ox = Graphics.width / 2
        @ani_oy = Graphics.height / 2
      else
        @ani_ox = viewport.rect.width / 2
        @ani_oy = viewport.rect.height / 2
      end
    else
      @ani_ox = x - ox + width / 2
      @ani_oy = y - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Disposição da animação
  #--------------------------------------------------------------------------
  def dispose_animation
    if @ani_bitmap1
      @@_reference_count[@ani_bitmap1] -= 1
      if @@_reference_count[@ani_bitmap1] == 0
        @ani_bitmap1.dispose
      end
    end
    if @ani_bitmap2
      @@_reference_count[@ani_bitmap2] -= 1
      if @@_reference_count[@ani_bitmap2] == 0
        @ani_bitmap2.dispose
      end
    end
    if @ani_sprites
      @ani_sprites.each {|sprite| sprite.dispose }
      @ani_sprites = nil
      @animation = nil
    end
    @ani_bitmap1 = nil
    @ani_bitmap2 = nil
  end
  #--------------------------------------------------------------------------
  # * Atualização da animação
  #--------------------------------------------------------------------------
  def update_animation
    return unless animation?
    @ani_duration -= 1
    if @ani_duration % @ani_rate == 0
      if @ani_duration > 0
        frame_index = @animation.frame_max
        frame_index -= (@ani_duration + @ani_rate - 1) / @ani_rate
        animation_set_sprites(@animation.frames[frame_index])
        @animation.timings.each do |timing|
          animation_process_timing(timing) if timing.frame == frame_index
        end
      else
        end_animation
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Finalização da animação
  #--------------------------------------------------------------------------
  def end_animation
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # * Definir sprites da animação
  #     frame : informação do quadro（RPG::Animation::Frame）
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @ani_ox - cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @ani_ox + cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento de sincronismo do Flash e SE
  #     timing : informação de sincronismo （RPG::Animation::Timing）
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play unless @ani_duplicated
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * @ani_rate)
    when 2
      if viewport && !@ani_duplicated
        viewport.flash(timing.flash_color, timing.flash_duration * @ani_rate)
      end
    when 3
      self.flash(nil, timing.flash_duration * @ani_rate)
    end
  end
end
