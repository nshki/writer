#========================================================================
# _base.coffee
#========================================================================

#------------------------------------------------------------------------
# Canvas is instantiated on an element with class "canvas" and manages
# the high-level document activity.
#------------------------------------------------------------------------
class Canvas

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @cursor           = new Cursor(@el)
    window.onkeydown  = @cursor.keydown_listener
    window.onkeypress = @cursor.keypress_listener
    window.onfocus    = @focus_listener
    window.onblur     = @blur_listener

  # Fade in on focus
  #----------------------------------------------------------------------
  focus_listener: (e) =>
    @el.className = "canvas focus"

  # Fade out on blur
  #----------------------------------------------------------------------
  blur_listener: (e) =>
    @el.className = "canvas"

#------------------------------------------------------------------------
# Cursor controls the behavior of the blinking I-beam. Any typing or
# action keys / shortcuts respond to the methods defined by this class.
#------------------------------------------------------------------------
class Cursor

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @el               = document.createElement("div")
    @el.className     = "cursor"
    @el.style.height  = @get_char_height() + "px"
    @canvas.appendChild(@el)
    @pos              = 0

  # Helper for constructor. Returns the height of a blank character.
  #----------------------------------------------------------------------
  get_char_height: () =>
    # Create new blank character
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = "&nbsp;"
    @canvas.appendChild(char)

    # Calculate total box model height
    char_comp   = document.defaultView.getComputedStyle(char, "")
    char_height = char.offsetHeight +
                  parseInt(char_comp.getPropertyValue("margin-top")) +
                  parseInt(char_comp.getPropertyValue("margin-bottom"))

    # Remove blank character and return the height
    @canvas.removeChild(char)
    char_height

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
    @pos             += 1
    newline           = document.createElement("br")
    newline.className = "newline"
    @canvas.insertBefore(newline, @el)

  # Move cursor left
  #----------------------------------------------------------------------
  move_left: () =>
    if @pos > 0
      previous_el = @canvas.children[@pos-1]
      @pos       -= 1
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
      @pos        += 1

      # If we reached the end of our typing, append the cursor,
      # otherwise, insert into appropriate location.
      if last_pos then @canvas.appendChild(@el)
      else             @canvas.insertBefore(@el, next_next_el)
    else @error()

  # Move cursor down
  #----------------------------------------------------------------------
  move_down: () =>
    # The first element* is the cursor itself, the second element is the
    # character that the cursor is on, and the third element is the
    # element we need to jump to.
    #
    # * Necessary to define "first element," as cursor can be on
    #   different lines. Defined as base_index below.
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)
    if col_els[base_index+2]
      @canvas.insertBefore(@el, col_els[base_index+2])
    else
      @canvas.appendChild(@el)
    @pos = @get_cursor_pos()

  # Move cursor up
  #----------------------------------------------------------------------
  move_up: () =>
    # The element directly before the cursor in the new array is the
    # element we need to jump to.
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)
    if col_els[base_index-1]
      @canvas.insertBefore(@el, col_els[base_index-1])
    else
      if @canvas.children[0]
        @canvas.insertBefore(@el, @canvas.children[0])
    @pos = @get_cursor_pos()

  # Helper for move_down() and move_up(). Store and return an array of
  # elements that have the same left offset as the cursor.
  #----------------------------------------------------------------------
  get_col_els: () =>
    col_els  = []
    col_left = @el.offsetLeft
    for el in @canvas.children
      col_els.push(el) if el.offsetLeft == col_left
    col_els

  # Helper for move_down() and move_up(). Convert an HTMLCollection
  # object to array and return the position of the cursor.
  #----------------------------------------------------------------------
  get_cursor_pos: () =>
    canvas_els = Array.prototype.slice.call(@canvas.children)
    canvas_els.indexOf(@el)

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
      when 38 then @move_up()
      when 39 then @move_right()
      when 40 then @move_down()
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
