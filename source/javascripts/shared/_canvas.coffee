#------------------------------------------------------------------------
# Canvas
#------------------------------------------------------------------------

class window.Canvas

  base_class: "canvas transition"
  keys:       {}
  focus_mode: false

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @el.className     = "#{@base_class} focus"
    @el.onpaste       = @paste_listener
    @caret            = new Caret(@el)
    window.onkeypress = @keypress_listener
    window.onkeydown  = @keydown_listener
    window.onkeyup    = @keyup_listener
    window.onfocus    = @focus_listener
    window.onblur     = @blur_listener
    window.onresize   = @resize_listener; @resize_listener()

    Elements.focus_button.onclick = () =>
      @focus_mode = !@focus_mode
      @el.classList.toggle("focus-mode")
      Elements.focus_button.classList.toggle("on")
      Helpers.focus_mode(@el, @caret.pos) if @focus_mode

  # Handle typed characters
  #----------------------------------------------------------------------
  keypress_listener: (e) =>
    if e.which != 13 and e.which != 32
      char = String.fromCharCode(e.which)
      @caret.type(char)
      window.getSelection().collapse()
      Helpers.ensure_visible(@el, @caret)
      Helpers.focus_mode(@el, @caret.pos) if @focus_mode

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    @keys[e.which] = true

    # Detect command/ctrl
    if @keys[91] or @keys[93] or @keys[224] or @keys[17]
      # 91, 93 => WebKit
      # 224    => Firefox
      # 17     => Opera
      cmd = true
    else cmd = false

    # Detect alt
    if @keys[18] then alt = true
    else              alt = false

    # Will be true if any of the below keys are pressed
    exec = false
    switch e.which
      when 8  then @caret.delete(e);   exec = true
      when 9  then @caret.tab(e);      exec = true
      when 13 then @caret.enter();     exec = true
      when 32 then @caret.spacebar(e); exec = true

      # Arrow keys
      when 37
        if      cmd then @caret.move_cmd_left(e)
        else if alt then @caret.move_alt_left(e)
        else             @caret.move_left(e)
        exec = true
      when 38
        if cmd then @caret.move_cmd_up(e)
        else        @caret.move_up(e)
        exec = true
      when 39
        if      cmd then @caret.move_cmd_right(e)
        else if alt then @caret.move_alt_right(e)
        else             @caret.move_right(e)
        exec = true
      when 40
        if cmd then @caret.move_cmd_down(e)
        else        @caret.move_down(e)
        exec = true

    # Clear selections and ensure caret visibility only if a defined
    # caret action was performed.
    if exec == true
      window.getSelection().collapse()
      Helpers.ensure_visible(@el, @caret)
      Helpers.focus_mode(@el, @caret.pos)

  # Forget pressed keys
  #----------------------------------------------------------------------
  keyup_listener: (e) =>
    @keys[e.which] = false

  # Fade in on focus
  #----------------------------------------------------------------------
  focus_listener: (e) =>
    @el.className = "#{@base_class} focus"
    @el.classList.add("focus_mode") if @focus_mode

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

  # Handle re-wordwrapping and canvas resize on window resize
  #----------------------------------------------------------------------
  resize_listener: () =>
    Helpers.wordwrap(@el)
    @caret.set_pos(Helpers.get_caret_pos(@el, @caret.el))
    @el.style.height = "#{window.innerHeight-Elements.canvas_menu.offsetHeight}px"

