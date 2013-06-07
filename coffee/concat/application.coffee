#========================================================================
# canvas.coffee
#
# Canvas manages high-level document activity.
#========================================================================
class Canvas

  base_class: "canvas transition"

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@el) ->
    @el.className     = "#{@base_class} focus"
    @el.onpaste       = @paste_listener
    @cursor           = new Cursor(@el)
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
      @cursor.type(char)

  # Handle action keys
  #----------------------------------------------------------------------
  keydown_listener: (e) =>
    switch e.which
      when 8  then @cursor.delete(e)
      when 9  then @cursor.tab(e)
      when 13 then @cursor.enter()
      when 32 then @cursor.spacebar()
      when 37 then @cursor.move_left()
      when 38 then @cursor.move_up()
      when 39 then @cursor.move_right()
      when 40 then @cursor.move_down()

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
        @cursor.spacebar()
      else if paste_text[i] == "\n"
        @cursor.enter()
      else
        @cursor.type(paste_text[i])

#========================================================================
# cursor.coffee
#
# Cursor controls the behavior of the blinking I-beam. Any typing or
# action keys / shortcuts respond to the methods defined by this class.
#========================================================================
class Cursor

  pos:      0
  tab_size: 4

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @el              = document.createElement("div")
    @el.className    = "cursor"
    @el.style.height = @get_char_height() + "px"
    @canvas.appendChild(@el)

  # Creates a new character element based on the ASCII value passed
  #----------------------------------------------------------------------
  type: (_char) =>
    window.getSelection().collapse()
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = _char
    @canvas.insertBefore(char, @el)
    @pos += 1

  # Tabs x spaces, where x is defined as an instance variable
  #----------------------------------------------------------------------
  tab: (e) =>
    e.preventDefault()
    window.getSelection().collapse()
    @spacebar() for i in [0...@tab_size]

  # Duplicate standard spacebar behavior
  #----------------------------------------------------------------------
  spacebar: () =>
    @type("&nbsp;")

  # Duplicate standard return / enter behavior
  #----------------------------------------------------------------------
  enter: () =>
    window.getSelection().collapse()
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
    window.getSelection().collapse()
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
    window.getSelection().collapse()
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
    window.getSelection().collapse()
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)

    # If there is a next element, execute the if. Otherwise, move the
    # cursor to the end.
    if col_els[base_index+1]

      # Define low_el to be the next element while handling the special
      # case.
      low_el = col_els[base_index+1]
      low_el = col_els[base_index+2] if col_els[base_index+2]

      # If the next element is more than two rows down, move the
      # cursor to the next newline. Otherwise, move down normally.
      if low_el.offsetTop > (@el.offsetTop + @el.offsetHeight)
        cursor_pos = @pos
        until @canvas.children[cursor_pos].className == "newline"
          cursor_pos += 1
        @canvas.insertBefore(@el, @canvas.children[cursor_pos+1])

      # Move down normally. If at the last row, move to end.
      else
        if low_el.offsetTop == @el.offsetTop
          @canvas.appendChild(@el)
        else
          @canvas.insertBefore(@el, low_el)

    # Move the cursor to the end. If there is no end, error.
    else
      if @pos < @canvas.children.length-1
        @canvas.appendChild(@el)
      else @error()

    @pos = @get_cursor_pos()

  # Move cursor up
  #----------------------------------------------------------------------
  move_up: () =>
    # The element directly before the cursor in the new array is the
    # element we need to jump to.
    window.getSelection().collapse()
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)

    # If there is an element directly above the cursor, execute the if
    # branch. Otherwise, move the cursor to the beginning.
    if col_els[base_index-1]

      # If the element before the cursor is more than one row higher
      # than the cursor, move the cursor to the end of the next highest
      # row. Otherwise, move the cursor up normally.
      high_el = col_els[base_index-1]
      if high_el.offsetTop < (@el.offsetTop - @el.offsetHeight)

        # Calculate position of the closest newline before the cursor
        # and place the cursor before it.
        cursor_pos = @pos
        until @canvas.children[cursor_pos].className == "newline"
          cursor_pos -= 1
        @canvas.insertBefore(@el, @canvas.children[cursor_pos])

      # Move cursor up normally
      else @canvas.insertBefore(@el, col_els[base_index-1])

    # Move cursor to the beginning. If there is no beginning, error.
    else
      if @pos > 0
        @canvas.insertBefore(@el, @canvas.children[0])
      else @error()

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

#========================================================================
# main.coffee
#========================================================================

#------------------------------------------------------------------------
# Instantiate a new Canvas
#------------------------------------------------------------------------
canvas = document.querySelector(".canvas")
canvas = new Canvas(canvas)