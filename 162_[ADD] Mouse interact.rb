#==============================================================================
# Interagir com eventos usando o mouse
# Compatível com Sistema online de Valentine (VXA-OS)
# Autor: Alberto Andrart (Shiy)
#==============================================================================

class Scene_Map < Scene_Base
  alias update_event_click update
  def update
    update_event_click
    return if $game_map.interpreter.running?
    return unless valid_event_click?

    x = Mouse.tile_x
    y = Mouse.tile_y

    # Ativa o evento clicado, mesmo sem estar virado
    start_map_event(x, y)
  end

  def valid_event_click?
    return false unless Mouse.click?(:R)
    return false if $game_map.interpreter.running?
    return false if $game_message.busy?
    return false unless $game_map.valid?(Mouse.tile_x, Mouse.tile_y)
    return false if over_blocking_window?
    true
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

  def start_map_event(x, y)
    $game_map.events_xy(x, y).each do |event|
      if [1, 2].include?(event.trigger) && event.list && !event.jumping? && event.normal_priority?
        event.start
      end
    end
  end
end
