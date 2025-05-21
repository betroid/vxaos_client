class Sprite_Desc < Sprite
  # Configurações editáveis
  WINDOW_WIDTH  = 200
  MARGIN        = 8
  LINE_HEIGHT   = 18
  SPACING_TITLE_RARITY = 4
  SPACING_RARITY_DESC = 12
  SPACING_DESC_ATTR_HEADER = 20
  SPACING_ATTR_HEADER_ATTRS = 8
  ATTRIBUTES_PER_ROW = 3
  MAX_DESC_LINES = 3

  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(1, 1)
    self.visible = false
    self.z = 9999
  end

  # --- MÉTODOS DE DESENHO (definidos ANTES de serem chamados) ---
  def draw_basic
    y = 0
    name_color = item_rarity(@item)[1]

    # Nome centralizado no topo
    self.bitmap.font.color.set(name_color)
    self.bitmap.draw_text(0, y, self.bitmap.width, LINE_HEIGHT, @item.name, 1)

    y += LINE_HEIGHT + SPACING_TITLE_RARITY

    # Raridade com "Tipo de item:"
    rarity = item_rarity(@item)
    self.bitmap.font.color.set(rarity[1])
    self.bitmap.draw_text(MARGIN, y, self.bitmap.width - MARGIN * 2, LINE_HEIGHT, "Tipo de item: #{rarity[0]}", 1)

    y += LINE_HEIGHT + SPACING_RARITY_DESC

    # Descrição centralizada
    self.bitmap.font.color.set(Color.new(255, 255, 255))
    desc_lines = $windows[:item].word_wrap(@item.description.delete("\n"), self.bitmap.width - MARGIN * 2)[0, MAX_DESC_LINES]
    desc_lines.each_with_index do |text, i|
      self.bitmap.draw_text(MARGIN, y + LINE_HEIGHT * i, self.bitmap.width - MARGIN * 2, LINE_HEIGHT, text, 1)
    end

    @desc_end_y = y + desc_lines.size * LINE_HEIGHT
  end

  def draw_attribute_header
    return unless @item.is_a?(RPG::Weapon) || @item.is_a?(RPG::Armor)
    y = @desc_end_y + SPACING_DESC_ATTR_HEADER
    self.bitmap.font.color.set(Color.new(0, 255, 0))
    self.bitmap.draw_text(MARGIN, y, self.bitmap.width - MARGIN * 2, LINE_HEIGHT, "ATRIBUTOS", 1)
    @attrs_start_y = y + LINE_HEIGHT + SPACING_ATTR_HEADER_ATTRS
  end

  def draw_attributes
    return unless @item.is_a?(RPG::Weapon) || @item.is_a?(RPG::Armor)
    y = @attrs_start_y
    @item.params.each_with_index do |value, param_id|
      x = MARGIN + (param_id % ATTRIBUTES_PER_ROW) * 70
      row = (param_id / ATTRIBUTES_PER_ROW)
      current_y = y + row * LINE_HEIGHT

      name = Vocab::param(param_id)
      self.bitmap.font.color.set(Color.new(218, 165, 32))
      self.bitmap.draw_text(x, current_y, 60, LINE_HEIGHT, "#{name}:", 0)

      self.bitmap.font.color.set(Color.new(255, 255, 255))
      text_width = self.bitmap.text_size("#{name}:").width
      self.bitmap.draw_text(x + text_width + 5, current_y, 30, LINE_HEIGHT, value.to_s, 0)
    end
  end

  def draw_price
    return unless $windows[:shop].visible
    rect_x = MARGIN
    rect_y = self.bitmap.height - (LINE_HEIGHT + 15)
    rect_width = self.bitmap.width - MARGIN * 2
    rect_height = LINE_HEIGHT + 6

    self.bitmap.fill_rect(rect_x, rect_y, rect_width, rect_height, Color.new(0, 0, 0, 160))

    border_color = Color.new(218, 165, 32)
    self.bitmap.fill_rect(rect_x, rect_y, rect_width, 1, border_color)
    self.bitmap.fill_rect(rect_x, rect_y + rect_height - 1, rect_width, 1, border_color)
    self.bitmap.fill_rect(rect_x, rect_y, 1, rect_height, border_color)
    self.bitmap.fill_rect(rect_x + rect_width - 1, rect_y, 1, rect_height, border_color)

    price = $windows[:shop].in_area? ? $windows[:shop].price[@item] : @item.price / 2
    price_text = "$ #{format_number(price)}"
    self.bitmap.font.color.set(Color.new(255, 255, 255))
    self.bitmap.draw_text(rect_x + 5, rect_y + 3, rect_width - 10, LINE_HEIGHT, price_text, 1)
  end

  def draw_skill_text
    y = 0

    # Nome centralizado no topo
    self.bitmap.font.color.set(Color.new(255, 215, 0))
    self.bitmap.draw_text(0, y, self.bitmap.width, LINE_HEIGHT, @item.name, 1)

    y += LINE_HEIGHT + SPACING_TITLE_RARITY

    # Descrição centralizada, todas as linhas
    self.bitmap.font.color.set(Color.new(255, 255, 255))
    desc_lines = $windows[:item].word_wrap(@item.description.delete("\n"), self.bitmap.width - MARGIN * 2)
    desc_lines.each_with_index do |text, i|
      self.bitmap.draw_text(MARGIN, y + LINE_HEIGHT * i, self.bitmap.width - MARGIN * 2, LINE_HEIGHT, text, 1)
    end
  end

  # --- MÉTODOS PRINCIPAIS ---
  def refresh(item)
    return unless item
    @item = item
    
    adjust_window_size
    return if self.bitmap.disposed?

    draw_background
    draw_title_bar
    draw_icon
    
    if @item.is_a?(RPG::Skill)
      draw_skill_text
    else
      draw_basic
      draw_attribute_header
      draw_attributes
      draw_price
    end
  end

  def adjust_window_size
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?

    desc_lines = $windows[:item].word_wrap(@item.description.delete("\n"), WINDOW_WIDTH - MARGIN * 2) rescue [""]

    if @item.is_a?(RPG::Skill)
      desc_lines = desc_lines[0, desc_lines.size]
      desc_height = desc_lines.size * LINE_HEIGHT
      total_height = LINE_HEIGHT + SPACING_TITLE_RARITY + desc_height + MARGIN * 2
      total_height = [total_height, 80].max
      self.bitmap = Bitmap.new(WINDOW_WIDTH, total_height)
    else
      desc_lines = desc_lines[0, MAX_DESC_LINES]
      desc_height = desc_lines.size * LINE_HEIGHT

      attr_count = (@item.is_a?(RPG::Weapon) || @item.is_a?(RPG::Armor)) ? @item.params.size : 0
      attr_rows = (attr_count.to_f / ATTRIBUTES_PER_ROW).ceil
      attr_height = attr_rows * LINE_HEIGHT

      base_height = LINE_HEIGHT * 2 + SPACING_TITLE_RARITY + SPACING_RARITY_DESC + desc_height + 
                   SPACING_DESC_ATTR_HEADER + LINE_HEIGHT + SPACING_ATTR_HEADER_ATTRS + attr_height
      total_height = base_height + LINE_HEIGHT + 20 + MARGIN

      self.bitmap = Bitmap.new(WINDOW_WIDTH, [total_height, 120].max)
    end
    self.visible = true
  end

  def draw_background
    self.bitmap.clear
    self.bitmap.fill_rect(self.bitmap.rect, Color.new(0, 0, 0, 160))
  end

  def draw_title_bar
    self.x = Mouse.x + 12 + self.bitmap.width > Graphics.width ? Graphics.width - self.bitmap.width : Mouse.x + 12
    self.y = Mouse.y - self.bitmap.height - 12 < 0 ? Mouse.y + 12 : Mouse.y - self.bitmap.height - 12

    bar_height = LINE_HEIGHT + 2
    self.bitmap.fill_rect(0, 0, self.bitmap.width, bar_height, Color.new(60, 60, 60, 200))
  end

  def draw_icon
    return unless @item.icon_index
    iconset = Cache.system("Iconset")
    icon_index = @item.icon_index % (iconset.width / 24 * iconset.height / 24)
    icon_x = (icon_index % 16) * 24
    icon_y = (icon_index / 16) * 24
    self.bitmap.blt(MARGIN, 2, iconset, Rect.new(icon_x, icon_y, 24, 24))
  end

  def item_rarity(item)
    return ["Normal", Color.new(255, 255, 255)] unless item.is_a?(RPG::BaseItem)
    note = item.note[/\<raridade:(.*?)\>/i, 1] rescue nil
    case note
    when "comum"    then ["Comum", Color.new(255, 255, 255)]
    when "incomum"  then ["Incomum", Color.new(30, 144, 255)]
    when "raro"     then ["Raro", Color.new(218, 165, 32)]
    else ["Normal", Color.new(255, 255, 255)]
    end
  end

  def dispose
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    super
  end

  private

  def format_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end
end