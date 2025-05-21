#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  Esta é a superclasse de todas as janelas selecionáveis
# do jogo. Ela lida com as funções de movimento do cursor
# e rolagem.
# Hierarquia: W_Base > Window_Base > W_Selectable >
# Window_Selectable > W_ItemSelectable > Window_ItemSelectable
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module W_Selectable
  
  def line_height
    24
  end
  
  def item_max
    @data.size
  end
  
  def make_list
  end
  
  def refresh
    make_list
    create_contents
    draw_all_items
  end
  
  def process_cursor_move
    return if self.is_a?(Window_Command) && !active
    return if $cursor.object
    return if $dragging_window
    last_index = @index
    unselect
    # Muda o índice, que foi alterado para -1 (unselect),
    #se a área da janela é selecionável
    if selectable_area?
      item_max.times do |i|
        rect = item_rect(i)
        if in_area?(contents_x + rect.x - 2, cursor_y(rect.y), cursor_width(rect.width), rect.height)
          select(i)
          Sound.play_cursor unless @index == last_index
          break
        end
      end
    end
  end
  
  def process_handling
    return unless open? && active
    return process_ok if ok_enabled? && Mouse.click?(:L)
    return process_cancel if cancel_enabled? && Input.trigger?(:B)
  end
  
end

#==============================================================================
# ** Window_Selectable
#==============================================================================
class Window_Selectable < Window_Base
  
  include W_Selectable
  
  def initialize(x, y, width, height)
    @data = []
    super
    @index = -1
    @handler = {}
    @cursor_fix = false
    @cursor_all = false
    update_padding
    deactivate
  end
  
  def cursor_y(rect_y)
    rect_y + 10
  end
  
  def cursor_width(rect_width)
    rect_width
  end
  
  def selectable_area?
    Mouse.y <= self.y + self.height
  end
  
end

#==============================================================================
# ** Window_Selectable2
#==============================================================================
class Window_Selectable2 < Window_Base2
  
  include W_Selectable
  
  attr_reader   :index
  
  def initialize(x, y, window, cursor_image = '')
    @cursor_image = cursor_image
    @data = []
    super(x, y, window)
    @index = -1
  end
  
  def col_max
    1
  end
  
  def spacing
    32
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def item_height
    line_height
  end
  
  def row_max
    [(item_max + col_max - 1) / col_max, 1].max
  end
  
  def contents_height
    [super - super % item_height, row_max * item_height].max
  end
  
  def cursor_y(rect_y)
    rect_y + contents_y - self.oy
  end
  
  def cursor_width(rect_width)
    [rect_width, contents_width - 10].min
  end
  
  def selectable_area?
    Mouse.y >= self.y + contents_y && Mouse.y <= self.y + self.height - 20
  end
  
  def dispose
    super
    if @cursor_sprite
      @cursor_sprite.bitmap.dispose
      @cursor_sprite.dispose
    end
  end
  
  def index=(index)
    @index = index
    @cursor_sprite.visible = (@index >= 0) if @cursor_sprite
  end
  
  def select(index)
    self.index = index if index
  end
  
  def unselect
    self.index = -1
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
  
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect
  end
  
  def create_contents
    create_cursor if !@cursor_image.empty? && !@cursor_sprite
    super
  end
  
  def create_cursor
    bitmap = Cache.system(@cursor_image)
    @cursor_sprite = Sprite.new
    @cursor_sprite.bitmap = Bitmap.new(cursor_width(item_width), bitmap.height)
    @cursor_sprite.bitmap.blt(0, 0, bitmap, Rect.new(0, 0, 4, bitmap.height))
    @cursor_sprite.bitmap.stretch_blt(Rect.new(4, 0, @cursor_sprite.bitmap.width - 8, height), bitmap, Rect.new(4, 0, 10, bitmap.height))
    @cursor_sprite.bitmap.blt(@cursor_sprite.bitmap.width - 4, 0, bitmap, Rect.new(14, 0, 4, bitmap.height))
    @cursor_sprite.z = self.z
    @cursor_sprite.visible = false
  end
  
  def visible=(visible)
    super
    @cursor_sprite.visible = false if @cursor_sprite && !visible
  end
  
  def draw_all_items
    item_max.times { |i| draw_item(i) }
  end

  def update
    super
    process_cursor_move
    if @cursor_sprite
      rect = item_rect(@index)
      @cursor_sprite.x = @contents.x + rect.x
      @cursor_sprite.y = @contents.y + rect.y - self.oy
    end
  end
  
end

#==============================================================================
# ** W_ItemSelectable
#==============================================================================
module W_ItemSelectable
  
  def create_gold_bar
    @gold_sprite = Sprite.new
    @gold_sprite.bitmap = Bitmap.new(contents_width - 8, 22)
    @gold_x = (width - @gold_sprite.bitmap.width) / 2
    @gold_y = height - 40
    @gold_sprite.x = x + @gold_x
    @gold_sprite.y = y + @gold_y
    @gold_sprite.visible = visible
    @gold_sprite.z = z
  end
  
  def dispose
    super
    if @gold_sprite
      @gold_sprite.bitmap.dispose
      @gold_sprite.dispose
    end
  end
  
  def visible=(visible)
    super
    @gold_sprite.visible = visible if @gold_sprite
  end
  
  def col_max
    6
  end
  
  def spacing
    6
  end
  
  def item_max
    @data ? @data.size : 1
  end
  
  def item_width
    24
  end
  
  def enable?(item)
    true
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * (item_height + spacing)
    rect
  end
  
  def item
    @data[index]
  end
  
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      draw_icon(item.icon_index, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
  
  def draw_item_number(rect, item)
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
    refresh_gold_bar if @gold_sprite
  end
  
  def refresh_gold_bar
    bitmap = Cache.system('GoldBar')
    @gold_sprite.bitmap.clear
    @gold_sprite.bitmap.blt(0, 0, bitmap, Rect.new(0, 0, 4, bitmap.height))
    rect = Rect.new(4, 0, @gold_sprite.bitmap.width - 8, @gold_sprite.bitmap.height)
    @gold_sprite.bitmap.stretch_blt(rect, bitmap, Rect.new(4, 0, 10, bitmap.height))
    @gold_sprite.bitmap.blt(@gold_sprite.bitmap.width - 4, 0, bitmap, Rect.new(14, 0, 4, bitmap.height))
    @gold_sprite.bitmap.draw_text(0, -1, @gold_sprite.bitmap.width - 5, line_height, "$ #{format_number(gold)}", 2)
  end
  
  def update
    super
    update_desc
    update_drag
    update_drop
    if @gold_sprite
      @gold_sprite.x = x + @gold_x
      @gold_sprite.y = y + @gold_y
    end
  end
  
  def process_handling
  end
  
  def update_desc
    if index >= 0 && !$cursor.object
      show_desc(item)
    else
      hide_desc
    end
  end
  
  def update_drag
  end
  
  def update_drop
  end
  
end

#==============================================================================
# ** Window_ItemSelectable
#==============================================================================
class Window_ItemSelectable < Window_Selectable
  
  include W_ItemSelectable
  
  def initialize(x, y, width, height)
    super
    create_desc
  end
  
end

#==============================================================================
# ** Window_ItemSelectable2
#==============================================================================
class Window_ItemSelectable2 < Window_Selectable2
  
  include W_ItemSelectable
  
  def initialize(x, y, window, cursor = '')
    super
    create_desc
  end
  
end

#==============================================================================
# ** Window_ChoiceList
#==============================================================================
class Window_ChoiceList < Window_Command
  
  def update_placement
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = fitting_height($game_message.choices.size)
    self.x = @message_window.x + @message_window.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
  end
  
  def call_ok_handler
    $game_message.choice_proc.call(index)
    $network.send_choice(index)
    close
  end
  
  def call_cancel_handler
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    $network.send_choice($game_message.choice_cancel_type - 1)
    close
  end
  
end

#==============================================================================
# ** Window_NumberInput
#==============================================================================
class Window_NumberInput < Window_Base

  def process_ok
    Sound.play_ok
    $network.send_choice(@number)
    deactivate
    close
  end
  
end

#==============================================================================
# ** Window_KeyItem
#==============================================================================
class Window_KeyItem < Window_ItemList
  
  def initialize(message_window)
    @message_window = message_window
    super(adjust_x, 0, 640, fitting_height(4))
    self.openness = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  
  def adjust_x
    Graphics.width / 2 - 320
  end
  
  def on_ok
    result = item ? item.id : 0
    $network.send_choice(result)
    close
  end
  
  def on_cancel
    $network.send_choice(0)
    close
  end
  
end
