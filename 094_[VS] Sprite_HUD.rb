#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição de HP, MP, experiência,
# face e nível do jogador.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_HUD < Sprite2
  
  attr_reader :exp_sprite
  
  def initialize
    super
    self.bitmap = Bitmap.new(132 , 96)
    self.x = 4
    self.y = 8
    self.z = 50
    #self.bitmap.font.name = 'Ubuntu Light'
    self.bitmap.font.size = 18
    self.bitmap.font.shadow = true
    self.bitmap.font.outline = false
    self.bitmap.font.bold = true
    @back = Cache.system('HUDBase')
    create_exp_bar
    refresh
    change_opacity
  end
  
  def dispose
    super
    @exp_sprite.bitmap.dispose
    @exp_sprite.dispose
  end
  
  def create_exp_bar
		@exp_sprite = Sprite2.new
    @exp_sprite.bitmap = Bitmap.new(64, 22)
    @exp_sprite.x = 72
    @exp_sprite.y = 64
    @exp_sprite.dragable = false
		@exp_sprite.z = self.z
    @exp_sprite.change_opacity
    @exp_sprite.bitmap.font.color = (text_color(17))
  end
  
  def refresh
    draw_background
    draw_hp_bar
    draw_mp_bar
    draw_exp_bar
    draw_level
  end
  
  def draw_background
    self.bitmap.clear
    rect = Rect.new(0, 0, 248, 98)
    self.bitmap.blt(7, 0, @back, rect)
  end
    
  def draw_hp_bar
    #rect = Rect.new(0, 0, 123 * $game_actors[1].hp / $game_actors[1].mhp, 26)
    self.bitmap.draw_text(34, 7, 25, 18, 'VIT:', 1)
    self.bitmap.draw_text(20, 7, 96, 18, "#{$game_actors[1].hp}/#{$game_actors[1].mhp}", 2)
  end
  
  def draw_mp_bar
    #rect = Rect.new(0, 26, 123 * $game_actors[1].mp / $game_actors[1].mmp, 26)
    self.bitmap.draw_text(34, 35, 25, 18, 'ENE:', 1)
    self.bitmap.draw_text(20, 35, 96, 18, "#{$game_actors[1].mp}/#{$game_actors[1].mmp}", 2)
  end

  def draw_exp_bar
    @exp_sprite.bitmap.clear
    rect1 = Rect.new(0, 98, @exp_sprite.bitmap.width, @exp_sprite.bitmap.height)
    rect2 = Rect.new(0, 52, 308 * $game_actors[1].now_exp / $game_actors[1].next_exp, @exp_sprite.bitmap.height)
    exp = $game_actors[1].level >= Configs::MAX_LEVEL ? Vocab::MaxLevel : "#{$game_actors[1].now_exp * 100 / $game_actors[1].next_exp}%"
    @exp_sprite.bitmap.draw_text(0, 0, 50, 18, Vocab::Exp)
    @exp_sprite.bitmap.draw_text(32, 1, 30, 18, exp, 1)
  end
  
  def draw_level
    rect = Rect.new(0, 121, 80, 30)
    self.bitmap.blt(9, 56, @back, rect)
    self.bitmap.draw_text(32, 57, 30, 18, $game_actors[1].level, 1)
    self.bitmap.draw_text(10, 57, 30, 18, 'Nv:', 1)
  end
  

  def update
    super
    @exp_sprite.update
    @exp_sprite.change_opacity
  end
  
end
