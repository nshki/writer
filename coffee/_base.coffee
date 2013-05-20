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
    @base_class       = "canvas transition"
    @el.className     = @base_class
    @cursor           = new Cursor(@el)
    window.onkeydown  = @keydown_listener
    window.onkeypress = @keypress_listener
    window.onfocus    = @focus_listener
    window.onblur     = @blur_listener

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    switch e.which
      when 8  then @cursor.delete(e)
      when 13 then @cursor.enter()
      when 32 then @cursor.spacebar()
      when 37 then @cursor.move_left()
      when 38 then @cursor.move_up()
      when 39 then @cursor.move_right()
      when 40 then @cursor.move_down()

  # Handle typed characters
  #----------------------------------------------------------------------
  keypress_listener: (e) =>
    if e.which != 13 and e.which != 32
      char = String.fromCharCode(e.which)
      @cursor.type(char)

  # Fade in on focus
  #----------------------------------------------------------------------
  focus_listener: (e) =>
    @el.className = "#{@base_class} focus"

  # Fade out on blur
  #----------------------------------------------------------------------
  blur_listener: (e) =>
    @el.className = @base_class

#------------------------------------------------------------------------
# Cursor controls the behavior of the blinking I-beam. Any typing or
# action keys / shortcuts respond to the methods defined by this class.
#------------------------------------------------------------------------
class Cursor

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @pos             = 0
    @el              = document.createElement("div")
    @el.className    = "cursor"
    @el.style.height = @get_char_height() + "px"
    @canvas.appendChild(@el)

  # Creates a new character element based on the ASCII value passed
  #----------------------------------------------------------------------
  type: (_char) =>
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = _char
    @canvas.insertBefore(char, @el)
    @pos += 1

  # Duplicate standard spacebar behavior
  #----------------------------------------------------------------------
  spacebar: () =>
    @type("&nbsp;")

  # Duplicate standard return / enter behavior
  #----------------------------------------------------------------------
  enter: () =>
    @pos             += 1
    newline           = document.createElement("br")
    newline.className = "newline"
    @canvas.insertBefore(newline, @el)

  # Delete character located left of cursor
  #----------------------------------------------------------------------
  delete: (e) =>
    e.preventDefault()
    selection = window.getSelection()

    # The Selection API has a rangeCount property, but for some reason
    # it returned a 1 when there was nothing selected, so checking the
    # length of the toString() is a way around this.
    if selection.toString().length == 0
      before_cursor = @canvas.children[@pos-1]
      if before_cursor
        @pos -= 1
        @canvas.removeChild(before_cursor)
      else @error()
    else
      range      = selection.getRangeAt(0)
      range_head = range.startContainer.parentNode
      range_tail = range.endContainer.parentNode

      # If the cursor is not at the end of the selection, position the
      # cursor so that it is.
      if range_tail != @canvas
        @canvas.insertBefore(@el, range_tail)
        @pos = @get_cursor_pos()
        @move_right()

      # Delete until the selection is gone
      canvas_els      = Array.prototype.slice.call(@canvas.children)
      head_pos        = canvas_els.indexOf(range_head)
      times_to_delete = @pos - head_pos
      before_cursor   = @canvas.children[@pos-1]
      for i in [1..times_to_delete]
        @pos -= 1
        @canvas.removeChild(before_cursor)
        before_cursor = @canvas.children[@pos-1]

      # Clear the selection
      selection.collapse()

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
    # The first element* is the cursor itself, the second element* is the
    # character that the cursor is on, and the third element is the
    # element we need to jump to.
    #
    # * Necessary to define "first element," as cursor can be on
    #   different lines. Defined as base_index below.
    #
    # * There is one exception to the second element being the character
    #   the cursor is on, and this is when the cursor is at the end of
    #   a line.
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)
    if col_els[base_index+1]
      # Compare with the difference between cursor top offset
      if col_els[base_index+1].offsetTop == @el.offsetTop
        if col_els[base_index+2]
          @canvas.insertBefore(@el, col_els[base_index+2])
        else
          @canvas.appendChild(@el)
      else
        # Handle special end-of-line cursor case
        @canvas.insertBefore(@el, col_els[base_index+1])
    else @canvas.appendChild(@el)
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

  # Behavior on error
  #----------------------------------------------------------------------
  error: () =>
    @el.className = "cursor error"
    el = @el
    setTimeout ->
      el.className = "cursor"
    , 500

  # Helper for constructor. Returns the height of a blank character.
  #----------------------------------------------------------------------
  get_char_height: () =>
    # Create new blank character
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = "&nbsp;"
    @canvas.appendChild(char)

    # Calculate total box model height, then remove the blank character
    # and return the height.
    char_height = char.offsetHeight
    @canvas.removeChild(char)
    char_height

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
