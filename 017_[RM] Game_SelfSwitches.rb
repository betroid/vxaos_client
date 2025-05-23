#==============================================================================
# ** Game_SelfSwitches
#------------------------------------------------------------------------------
#  Esta classe gerencia os switches locais.
# A instância desta classe é referenciada por $game_self_switches.
#==============================================================================

class Game_SelfSwitches
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @data = {}
  end
  #--------------------------------------------------------------------------
  # * Aquisição da switch loca
  #     key : chave
  #--------------------------------------------------------------------------
  def [](key)
    @data[key] == true
  end
  #--------------------------------------------------------------------------
  # * Configuração do switch local
  #     key   : chave
  #     value : ON (true) / OFF (false)
  #--------------------------------------------------------------------------
  def []=(key, value)
    @data[key] = value
    on_change
  end
  #--------------------------------------------------------------------------
  # * Quando houver alteração
  #--------------------------------------------------------------------------
  def on_change
    $game_map.need_refresh = true
  end
end
