#========================================================================
# _base.coffee
#========================================================================

#------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------
get_char_height = () ->
  # Create new blank character
  canvas         = document.querySelector(".canvas")
  char           = document.createElement("div")
  char.className = "character"
  char.innerHTML = "&nbsp;"
  canvas.appendChild(char)

  # Calculate total box model height
  char_comp   = document.defaultView.getComputedStyle(char, "")
  char_height = char.offsetHeight +
                parseInt(char_comp.getPropertyValue("margin-top")) +
                parseInt(char_comp.getPropertyValue("margin-bottom"))

  # Remove blank character and return the height
  canvas.removeChild(char)
  char_height

#------------------------------------------------------------------------
# Cursor controls the behavior of the blinking I-beam. Any typing or
# action keys / shortcuts respond to the methods defined by this class.
#------------------------------------------------------------------------
class Cursor

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @el.style.height  = get_char_height() + "px"
    @pos              = 0
    window.onkeydown  = @keydown_listener
    window.onkeypress = @keypress_listener

  # Setter methods to link DOM elements
  #----------------------------------------------------------------------
  set_canvas: (@canvas) ->

  # Delete character located left of cursor
  #----------------------------------------------------------------------
  delete: (e) =>
    e.preventDefault()
    before_cursor = @canvas.children[@pos-1]

    if before_cursor
      @pos -= 1
      @canvas.removeChild(before_cursor)
    else @error()

  # Duplicate standard return / enter behavior
  #----------------------------------------------------------------------
  enter: () =>
    newline           = document.createElement("br")
    newline.className = "newline"
    @canvas.insertBefore(newline, @el)
    @pos += 1

  # Move cursor left
  #----------------------------------------------------------------------
  move_left: () =>
    if @pos > 0
      previous_el = @canvas.children[@pos-1]
      @pos -= 1
      @canvas.removeChild(@el)
      @canvas.insertBefore(@el, previous_el)
    else @error()

  # Move cursor right
  #----------------------------------------------------------------------
  move_right: () =>
    # Using -2 because:
    #
    #    | _ _
    #    0 1 2
    #
    # .insertBefore should be on element 2
    if @pos <= @canvas.children.length-2
      last_pos     = @pos == @canvas.children.length-2
      next_next_el = @canvas.children[@pos+2]
      @pos += 1
      @canvas.removeChild(@el)

      # If we reached the end of our typing, append the cursor,
      # otherwise, insert into appropriate location.
      if last_pos then @canvas.appendChild(@el)
      else             @canvas.insertBefore(@el, next_next_el)
    else @error()

  # Behavior on error
  #----------------------------------------------------------------------
  error: () =>
    @el.className = "cursor error"
    el = @el
    setTimeout ->
      el.className = "cursor"
    , 500

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    switch e.which
      when 8  then @delete(e)
      when 37 then @move_left()
      when 39 then @move_right()
      when 13 then @enter()

  # Handle typed characters
  #----------------------------------------------------------------------
  keypress_listener: (e) =>
    return if e.which == 13
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = String.fromCharCode(e.which)
    char.innerHTML = "&nbsp;" if char.innerHTML == " "
    @canvas.insertBefore(char, @el)
    @pos += 1

#------------------------------------------------------------------------
# Infopane watches for changes to a given canvas element and updates
# makes various data available to the user.
#------------------------------------------------------------------------
class Infopane

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @canvas.onchange = @onchange_listener

  # Watches for any changes to the given canvas
  #----------------------------------------------------------------------
  onchange_listener: () =>
    console.log "Change"
