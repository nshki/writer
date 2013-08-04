#------------------------------------------------------------------------
# Canvas
#------------------------------------------------------------------------

class window.Canvas

  base_class: "canvas transition"

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @el.className     = "#{@base_class} focus"
    @el.onpaste       = @paste_listener
    @caret            = new Caret(@el)
    @keys             = {}
    window.onkeypress = @keypress_listener
    window.onkeydown  = @keydown_listener
    window.onkeyup    = @keyup_listener
    window.onfocus    = @focus_listener
    window.onblur     = @blur_listener

  # Handle typed characters
  #----------------------------------------------------------------------
  keypress_listener: (e) =>
    if e.which != 13 and e.which != 32
      char = String.fromCharCode(e.which)
      @caret.type(char)

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    @keys[e.which] = true

    switch e.which
      when 8  then @caret.delete(e)
      when 9  then @caret.tab(e)
      when 13 then @caret.enter()
      when 32 then @caret.spacebar()

      # Arrow keys
      when 37
        if @keys[91] then @caret.move_all_left(e)
        else              @caret.move_left(e)
      when 38
        if @keys[91] then @caret.move_all_up(e)
        else              @caret.move_up(e)
      when 39
        if @keys[91] then @caret.move_all_right(e)
        else              @caret.move_right(e)
      when 40
        if @keys[91] then @caret.move_all_down(e)
        else              @caret.move_down(e)

    # Clear selections
    window.getSelection().collapse()

  # Forget pressed keys
  #----------------------------------------------------------------------
  keyup_listener: (e) =>
    @keys = {}

  # Fade in on focus
  #----------------------------------------------------------------------
  focus_listener: (e) =>
    @el.className = "#{@base_class} focus"

  # Fade out on blur
  #----------------------------------------------------------------------
  blur_listener: (e) =>
    @el.className = @base_class

  # Handle paste
  #----------------------------------------------------------------------
  paste_listener: (e) =>
    paste_text = e.clipboardData.getData("text/plain")
    for i in [0...paste_text.length]
      if paste_text[i] == " "
        @caret.spacebar()
      else if paste_text[i] == "\n"
        @caret.enter()
      else
        @caret.type(paste_text[i])
