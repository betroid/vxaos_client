#------------------------------------------------------------------------------#
#  Galv's Visibility Range
#------------------------------------------------------------------------------#

($imported ||= {})["Galv_Vis_Range"] = true
module Galv_Vis
 
#------------------------------------------------------------------------------#
#  SETTINGS - Don't forget to set these to unused variables and switch!
#------------------------------------------------------------------------------#
 
  SWITCH = 1      # This switch turns the visibility range on/off. Default OFF
 
  SIZEVAR = 1     # This variable controls how far player can see. Default 100
 
  OPACITYVAR = 2  # This variable controls the darkness opacity.   Default 255
 
#------------------------------------------------------------------------------#
#  END SETTINGS
#------------------------------------------------------------------------------#
 
end # Galv_Vis
 
 
class Spriteset_Map
  alias galv_vis_sm_initialize initialize
  def initialize
    create_visrange #if $game_switches[Galv_Vis::SWITCH]
    galv_vis_sm_initialize
  end
 
  def create_visrange
    @visrange = Sprite.new
    @visrange.bitmap = Cache.system("LuzMap")
    @visrange.ox = @visrange.bitmap.width / 2
    @visrange.oy = @visrange.bitmap.height / 2
  end
 
  alias galv_vis_sm_update update
  def update
    galv_vis_sm_update
    update_visrange
  end
 
  def update_visrange
    #if $game_switches[Galv_Vis::SWITCH]
      create_visrange if !@visrange
      @visrange.x = $game_player.screen_x
      @visrange.y = $game_player.screen_y - 16
      @visrange.opacity = 140 #$game_variables[Galv_Vis::OPACITYVAR]
      zoom = [100 * 0.01,0.5].max
      @visrange.zoom_x = zoom
      @visrange.zoom_y = zoom
   # else
   #   dispose_visrange
   # end
  end
 
  alias galv_vis_sm_dispose dispose
  def dispose
    galv_vis_sm_dispose
    dispose_visrange
  end
 
  def dispose_visrange
    return if !@visrange
    @visrange.bitmap.dispose
    @visrange.dispose
    @visrange = nil
  end
end # Spriteset_Map
 
 
module DataManager
  class << self
    alias galv_vis_dm_setup_new_game setup_new_game
  end
 
  def self.setup_new_game
    galv_vis_dm_setup_new_game
    $game_system.init_visvars
  end
end # DataManager
 
 
class Scene_Map
  attr_accessor :spriteset
end
 
class Game_System
  attr_accessor :visimage
 
  def init_visvars

  end
end
 
 
class Game_Interpreter
  def visimage(img)
    $game_system.visimage = img
    SceneManager.scene.spriteset.dispose_visrange
  end
end