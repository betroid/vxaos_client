#==============================================================================
# ** Window_Icon
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de ícones.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Icon < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 150, 45)
    @dragable = false
    self.windowskin = Cache.system('WindowClear')
    Icon.new(self, 0, 10, Configs::ITEM_ICON, "#{Vocab.item} (#{Configs::ITEM_KEY.to_s.delete('LETTER_')})") { $windows[:equip].trigger }
    Icon.new(self, 39, 10, Configs::FRIEND_ICON, "#{Vocab::Friend}s (#{Configs::FRIEND_KEY.to_s.delete('LETTER_')})") { $windows[:friend].trigger }
    Icon.new(self, 78, 10, Configs::GUILD_ICON, "#{Vocab::Guild} (#{Configs::GUILD_KEY.to_s.delete('LETTER_')})") { $windows[:guild].trigger }
    Icon.new(self, 117, 10, Configs::MENU_ICON, "#{Vocab::Menu} (#{Configs::MENU_KEY.to_s.delete('LETTER_')})") { $windows[:menu].trigger }
  end
  
  def adjust_x
    Graphics.width - 158
  end
  
  def adjust_y
    Graphics.height - 82
  end
  
end