DEFAULT_FONT = 'slkscr.ttf'
DEFAULT_FONT_SIZE = 20
DEFAULT_FONT_SPACING = 5

class Logger

  def initialize(world)
    @world = world
    @messages = []
    @used_texts = []
    @unused_texts = []
  end

  def print(text)
    @messages.push text
  end

  def clear
    @used_texts.each do |text|
      @unused_texts << text
      @used_texts.delete text
    end
    @unused_texts.each do |text|
      text.x = 0
      text.y = 0
      text.text = ''
    end
    @messages.clear
  end

  def draw
    text_height = DEFAULT_FONT_SIZE + DEFAULT_FONT_SPACING
    y_pos = @world.screen_height - (@messages.length * text_height)
    @messages.each do |message|
      text = get_or_create_text
      text.x = 0
      text.y = y_pos
      text.text = message
      y_pos += text_height
    end
  end

  private

  def get_or_create_text
    text = @unused_texts.first
    if text != nil
      @unused_texts.delete text
    else
      text = Text.new(size: DEFAULT_FONT_SIZE, font: DEFAULT_FONT)
    end

    @used_texts << text
    return text
  end

end
