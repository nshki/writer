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
      window.getSelection().collapse()

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    @keys[e.which] = true
    if @keys[91] or @keys[93] or @keys[224] or @keys[17] or e.ctrlKey
      # 91, 93 => WebKit
      # 224    => Firefox
      # 17     => Opera
      cmd = true
    else cmd = false

    # Will be true if any of the below keys are pressed
    exec = false
    switch e.which
      when 8  then @caret.delete(e);  exec = true
      when 9  then @caret.tab(e);     exec = true
      when 13 then @caret.enter();    exec = true
      when 32 then @caret.spacebar(); exec = true

      # Arrow keys
      when 37
        if cmd then @caret.move_all_left(e)
        else        @caret.move_left(e)
        exec = true
      when 38
        if cmd then @caret.move_all_up(e)
        else        @caret.move_up(e)
        exec = true
      when 39
        if cmd then @caret.move_all_right(e)
        else        @caret.move_right(e)
        exec = true
      when 40
        if cmd then @caret.move_all_down(e)
        else        @caret.move_down(e)
        exec = true

    # Clear selections
    window.getSelection().collapse() if exec == true

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
