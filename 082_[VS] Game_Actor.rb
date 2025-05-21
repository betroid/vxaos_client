#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  Esta classe lida com uma instância de cada jogador do
# mapa. Ela contém dados, como HP, MP, nível e experiência.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

#LM²
class Game_Battler < Game_BattlerBase
  def die
    @hp = 0
    states.each { |state| remove_state(state.id) if state.remove_at_battle_end }
    clear_buffs
  end
end

class Game_Actor < Game_Battler
  
  attr_reader   :party_members
  attr_reader   :quests
  attr_reader   :hotbar
  attr_accessor :sex
  attr_accessor :online_friends_size
  attr_accessor :points
  attr_accessor :friends
  attr_accessor :guild_name
  #LM² - Cooldown
  attr_accessor :states_time 
  attr_accessor :buffs_time
  attr_accessor :buffs_max_time
  attr_accessor :skills_cooldown_time
  
  def init_basic
    @sex = Enums::Sex::MALE
    @online_friends_size = 0
    @points = 0
    @party_members = {}
    @quests = {}
    @friends = []
    @hotbar = []
    @guild_name = ''
    #LM² - Cooldown
    @states_time = {}
    @buffs_time = Array.new(8,nil)
    @buffs_max_time = Array.new(8,0)
    @skills_cooldown_time = {}
  end
  
  def max_level
    Configs::MAX_LEVEL
  end
  
  def equip_slots
    slots = Configs::MAX_EQUIPS.times.to_a
    slots[1] = 0 if dual_wield?
    slots
  end
  
  def buff_icon_index(buff_level, param_id)
    if buff_level > 0
      return Configs::ICON_BUFF_START + (buff_level - 1) * 8 + param_id
    elsif buff_level < 0
      return Configs::ICON_DEBUFF_START + (-buff_level - 1) * 8 + param_id 
    else
      return 0
    end
  end
=begin
  def skill_wtype_ok?(skill)
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    if wtype_id1 > 0 && !wtype_equipped?(wtype_id1) || wtype_id2 > 0 && !wtype_equipped?(wtype_id2)
      $error_msg = Vocab::WTypeNotEquipped
      return false
    end
    return true
    #return true if wtype_id1 == 0 && wtype_id2 == 0
    #return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    #return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    #return false
  end
=end
  def change_exp(exp, show)
    @exp[@class_id] = [[exp, exp_for_level(Configs::MAX_LEVEL)].min, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    display_level_up if show && @level > last_level
    refresh
  end
  
  def now_exp
    exp - current_level_exp
  end
  
  def next_exp
    next_level_exp - current_level_exp
  end
  
  def param_max(param_id)
    Configs::MAX_PARAMS
  end
  
  def param_base(param_id)
    0
  end
  
  def quests_in_progress
    @quests.values.select(&:in_progress?)
  end
  
  def quests_finished
    @quests.values.select(&:finished?)
  end
  
  def change_hotbar(id, type, item_id)
    @hotbar[id] = type == Enums::Hotbar::ITEM ? $data_items[item_id] : $data_skills[item_id]
  end
  
  def display_level_up
    $game_player.animation_id = Configs::LEVEL_UP_ANIMATION_ID
    @result.level_up = true
    $windows[:target_hud].refresh if $game_player.has_target? && $game_player.target.actor == self
  end
  
  def occasion_ok?(item)
    item.occasion < 3
  end
  
  #LM²
  def state_ids
    @states
  end
  
  #LM²
  def buff_ids
    icons = []
    @buffs.each_with_index {|lv, i| icons.push(i) if lv != 0 }
    icons
  end  
  
end
