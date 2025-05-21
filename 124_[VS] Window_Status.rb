#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de informações do
# jogador, como parâmetros, classe e pontos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Status < Window_Base
  
  def initialize
    super(adjust_x, adjust_y, 180, 323)
    @dragable = false
    self.visible = false
    self.closable = false
    self.title = Vocab.status
    #@param_buttons = []
    8.times do |param_id|
      #@param_buttons << Image_Button.new(self, 150, 22 * param_id + 33, 'Plus') {$network.send_add_param(param_id) }
    end
  end
  
  def adjust_x
    $windows[:equip].x
  end
  
  def adjust_y
    $windows[:equip].y
  end

  def refresh
    contents.clear
    #change_color(normal_color)
    change_color(text_color(21))
    draw_text(10, 88, 60, line_height, Vocab::Class)
    draw_text(10, 112, 60, line_height, "#{Vocab::hp_a}:")
    draw_text(10, 136, 60, line_height, "#{Vocab::mp_a}:")
    (2...8).each do |param_id|
    
    #Gráfico do personagem
    #draw_actor_graphic($game_actors[1], 24, 44)
    
    #Textos
    change_color(normal_color)
    
    
    draw_text(10, 10, 100, line_height, 'Nível: ' + $game_actors[1].level.to_s)
    draw_text(10, 24, 200, line_height, 'Exp.: ' + $game_actors[1].now_exp.to_s + '/' +  $game_actors[1].next_exp.to_s)
    
    #ATRIBUTOS
    change_color(text_color(5))
    draw_text(10, 56, 100, line_height, 'ATRIBUTOS')
    
    change_color(text_color(21))
    #Largura suficiente para os termos não abreviados
    draw_text(10, 22 * param_id + 114, 100, line_height, "#{Vocab::param(param_id)}:")

    end
    
    
    #draw_text(0, 196, 60, line_height, Vocab::Points)
    change_color(normal_color)
    draw_text(75, 88, 150, line_height, $game_actors[1].class.name)
    draw_text(75, 112, 70, line_height, "#{$game_actors[1].hp}/#{$game_actors[1].mhp}")
    draw_text(75, 136, 70, line_height, "#{$game_actors[1].mp}/#{$game_actors[1].mmp}")
    (2...8).each do |param_id|
    draw_text(75, 22 * param_id + 114, 40, line_height, $game_actors[1].param(param_id))
    end
    #draw_text(75, 196, 40, line_height, $game_actors[1].points > 0 ? $game_actors[1].points : 0)
    #@param_buttons.each { |button| button.enable = $game_actors[1].points > 0 }
  end
  
end
