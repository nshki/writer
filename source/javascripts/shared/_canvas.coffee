#------------------------------------------------------------------------
# Canvas
#------------------------------------------------------------------------

class window.Canvas

  keys:       {}
  focus_mode: false

  # Default constructor
  # @param el - HTML element
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @caret      = new Caret(@el)
    @el.onclick = @click_listener
    @el.onpaste = @paste_listener
    @el.classList.add("focus")
    @el.classList.add("transition")

    @create_menu()
    @create_ios_input()

    window.onkeypress = @keypress_listener
    window.onkeydown  = @keydown_listener
    window.onkeyup    = @keyup_listener
    window.onfocus    = @focus_listener
    window.onblur     = @blur_listener
    window.onresize   = @resize_listener; @resize_listener()

  # Create menu and menu items
  #----------------------------------------------------------------------
  create_menu: () =>
    @menu = document.createElement("menu")
    @menu.classList.add("canvas-menu")

    # Focus button
    focus_button = document.createElement("button")
    focus_button.classList.add("focus-toggle")
    @menu.appendChild(focus_button)

    # Focus button click event
    focus_button.onclick = () =>
      @focus_mode = !@focus_mode
      @el.classList.remove("focus-mode")
      focus_button.classList.remove("on")

      # If focus mode is active, highlight the current sentence and
      # change UI to indicate it is active.
      if @focus_mode
        @el.classList.add("focus-mode")
        focus_button.classList.add("on")
        @highlight_sentence(@caret.pos)

    # Add menu to document
    document.querySelector("body").appendChild(@menu)

  # Creates an input field for iOS to bring up the keyboard
  #----------------------------------------------------------------------
  create_ios_input: () =>
    input      = document.createElement("input")
    input.type = "text"
    input.classList.add("ios-keyboard")
    document.querySelector("body").appendChild(input)

  # Inserts break elements between words in the canvas to rid of
  # horizontal overflow.
  #----------------------------------------------------------------------
  wordwrap: () =>
    chars     = 0
    max_chars = parseInt((@el.offsetWidth-110)/10)

    # Remove any newlines that weren't manually entered
    for el in @el.children
      if el.classList.contains("newline") and !el.classList.contains("enter")
        @el.insertBefore(Caret.new_char("&nbsp;"), el)
        @el.removeChild(el)

    # Greedy algorithm for generating breaks for word wrap
    i = 0
    while i < @el.children.length
      el     = @el.children[i]
      chars += 1 if el.classList.contains("character")
      chars  = 0 if el.classList.contains("newline")

      # Once we count past the maximum number of characters, look back
      # to find a space. Once we find a space, insert a newline before it
      # and delete.
      if chars > max_chars
        char = @el.children[i]
        until char.innerHTML == "&nbsp;"
          i -= 1
          char = @el.children[i]
        @el.insertBefore(Caret.new_break(), char)
        @el.removeChild(char)
        chars = 0
      i += 1

  # Identifies current sentence/line and highlight it
  # @param pos - Caret integer position
  #----------------------------------------------------------------------
  highlight_sentence: (pos) =>
    delimiters = [".", "!", "?"]
    el.classList.remove("current") for el in @el.children

    # Find end of previous sentence
    prev_it = @el.children[pos-1]
    until !prev_it or delimiters.indexOf(prev_it.innerHTML) > -1 or
                      prev_it.classList.contains("enter")
      pos    -= 1
      prev_it = @el.children[pos-1]

    # Mark every character till next delimiter
    next_it = @el.children[pos]
    until !next_it or delimiters.indexOf(next_it.innerHTML) > -1 or
                      next_it.classList.contains("enter")
      next_it.classList.add("current")
      pos    += 1
      next_it = @el.children[pos]

    # Clear the caret of the current class
    @caret.el.classList.remove("current")

  # Adjust window scroll so that the caret is visible
  #----------------------------------------------------------------------
  ensure_visible: () =>
    coords   = @caret.get_coords()
    vpadding = 50    # Less than .canvas padding-top + caret height

    # Offscreen top
    until coords[1] >= @el.scrollTop+vpadding
      @el.scrollTop -= 10
      coords         = @caret.get_coords()

    # Offscreen bottom
    until coords[1]-@el.scrollTop <= @el.offsetHeight-vpadding
      @el.scrollTop += 10
      coords         = @caret.get_coords()

  # Handle typed characters
  # @param e - keypress event
  #----------------------------------------------------------------------
  keypress_listener: (e) =>
    if e.which != 13 and e.which != 32
      char = String.fromCharCode(e.which)
      @caret.type(char)

      @wordwrap() if @has_overflow()
      @ensure_visible()
      @highlight_sentence(@caret.pos) if @focus_mode

      window.getSelection().collapse()

  # Detects if there is a horizontal overflow on the canvas
  # @return boolean - True if overflow, false otherwise
  #----------------------------------------------------------------------
  has_overflow: () =>
    @el.scrollWidth > @el.clientWidth

  # Handle action keys
  # @param e - keydown event
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    @keys[e.which] = true

    # Detect command/ctrl
    # 91, 93 => WebKit
    # 224    => Firefox
    # 17     => Opera
    cmd = false
    cmd = true if @keys[91] or @keys[93] or @keys[224] or @keys[17]

    # Detect alt
    alt = false
    alt = true if @keys[18]

    # Detect shift
    shift = false
    shift = true if @keys[16]

    # Will be true if any of the below keys are pressed
    exec = false
    switch e.which

      # Delete
      when 8
        if      cmd then @caret.cmd_delete(e)
        else if alt then @caret.alt_delete(e)
        else             @caret.delete(e)
        exec = true

      # Default special keys
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
      @ensure_visible()
      @highlight_sentence(@caret.pos) if @focus_mode

  # Forget pressed keys
  # @param e - keyup event
  #----------------------------------------------------------------------
  keyup_listener: (e) =>
    @keys[e.which] = false

  # Fade in on focus
  # @param e - focus event
  #----------------------------------------------------------------------
  focus_listener: (e) =>
    @el.classList.add("focus")
    @keys = {}   # Fixes bug where alt/cmd are remembered on refocus

  # Fade out on blur
  # @param e - blur event
  #----------------------------------------------------------------------
  blur_listener: (e) =>
    @el.classList.remove("focus")

  # Handle click
  # @param e - click event
  #----------------------------------------------------------------------
  click_listener: (e) =>
    @highlight_sentence(@caret.pos)

  # Handle paste
  # @param e - paste event
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
    @wordwrap() if @has_overflow()
    @caret.recalculate_pos()
    @el.style.height = "#{window.innerHeight-@menu.offsetHeight}px"

  # Get the pixel height of a blank character in the canvas
  # @param  canvas - Document canvas
  # @return int    - Pixel height of blank character
  #----------------------------------------------------------------------
  @get_char_height: (canvas) =>
    # Create new blank character
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = "&nbsp;"
    canvas.appendChild(char)

    # Calculate total box model height, then remove the blank character
    # and return the height.
    char_height = char.offsetHeight
    canvas.removeChild(char)
    char_height
