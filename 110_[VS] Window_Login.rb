#==============================================================================
# ** Window_Login
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de entrada.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Login < Window_Base
  
  def initialize
    # Quando a resolução é alterada, a coordenada x é
    #reajustada no adjust_windows_position da Scene_Map
    super(adjust_x, 235, 212, 179)
    self.title = Vocab::Login
    @user_box = Text_Box.new(self, 19, 38, 174, Configs::MAX_CHARACTERS) { enable_login_button }
    @pass_box = Text_Box.new(self, 19, 84, 174, Configs::MAX_CHARACTERS, true) { enable_login_button }
    @newacc_button = Button.new(self, 22, 140, Vocab::Register) { create_account }
    @login_button = Button.new(self, 111, 140, Vocab::Connect, 79) { login }
    @login_button.enable = false
    load_user
    @remember = Check_Box.new(self, 19, 110, Vocab::Remember, !@user_box.text.empty?)
    @user_box.active = !@pass_box.active
    draw_contents
  end
  
  def adjust_x
    Graphics.width / 2 - 105
  end
  
  def draw_contents
    # Desenhar o conteúdo da janela uma única vez, e não
    #toda vez que a janela ficar visível (refresh)
    draw_text(7, 6, 75, line_height, "#{Vocab::Username}:")
    draw_text(7, 52, 75, line_height, "#{Vocab::Password}:")
  end
  
  def load_user
    return if $settings_file.user.empty?
    # Impede que o nome de usuário do arquivo de configurações
    #seja alterado toda vez que o texto do @user_box mudar,
    #mesmo que a caixa de verificação não esteja ativada
    @user_box.text = $settings_file.user.clone
    @pass_box.active = true
  end
  
  def save_user
    return unless @remember.checked && $settings_file.user != @user_box.text
    $settings_file.user = @user_box.text
    $settings_file.save
  end
  
  def create_account
    $windows[:create_acc].show
    $windows[:alert].hide
    hide
  end
  
  def login
    # Se o botão de login está desabilitado e pressionou Enter
    return unless @login_button.enable
    if !$network.server_online?
      $windows[:alert].show(Vocab::ServerOffline)
    else
      $network.send_login(@user_box.text, @pass_box.text)
    end
  end
  
  def enable_login_button
    @login_button.enable = (@user_box.text.strip.size >= Configs::MIN_CHARACTERS && @pass_box.text.strip.size >= Configs::MIN_CHARACTERS)
  end
  
  def update
    super
    close_windows
    ok if Input.trigger?(:C)
    update_cursor
  end
  
  def close_windows
    return unless Input.trigger?(:B)
    if $windows[:alert].visible || $windows[:config].visible
      $windows[:alert].hide
      $windows[:config].hide
    else
      SceneManager.exit
    end
  end
  
  def ok
    $windows[:alert].visible ? $windows[:alert].hide : login
  end
  
  def update_cursor
    return unless Input.trigger?(:TAB)
    return unless @user_box.active || @pass_box.active
    @user_box.active = !@user_box.active
    @pass_box.active = !@pass_box.active
  end
  
end
