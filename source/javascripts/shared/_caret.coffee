#------------------------------------------------------------------------
# Caret
#------------------------------------------------------------------------

class window.Caret

  pos:      0
  tab_size: 4

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @el              = document.createElement("div")
    @el.className    = "caret"
    @el.style.height = Helpers.get_char_height(@canvas) + "px"
    @canvas.appendChild(@el)

  # Creates a new character element based on the ASCII value passed
  #----------------------------------------------------------------------
  type: (_char) =>
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = _char
    @canvas.insertBefore(char, @el)
    @pos += 1

  # Tabs x spaces, where x is defined as an instance variable
  #----------------------------------------------------------------------
  tab: (e) =>
    e.preventDefault()
    @spacebar() for [0...@tab_size]

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

  # Delete character located left of caret
  # @return boolean - True on success false on error
  #----------------------------------------------------------------------
  delete: (e) =>
    e.preventDefault()
    selection = window.getSelection()

    # The Selection API has a rangeCount property, but for some reason
    # it returned a 1 when there was nothing selected, so checking the
    # length of the toString() is a way around this.
    if selection.toString().length == 0
      before_caret = @canvas.children[@pos-1]
      if before_caret
        @pos -= 1
        @canvas.removeChild(before_caret)
        true
      else @error()
    else
      range      = selection.getRangeAt(0)
      range_head = range.startContainer.parentNode
      range_tail = range.endContainer.parentNode

      # If the caret is not at the end of the selection, position the
      # caret so that it is.
      if range_tail != @canvas
        @canvas.insertBefore(@el, range_tail)
        @pos = Helpers.get_caret_pos(@canvas, @el)
        @move_right()

      # Delete until the selection is gone
      canvas_els      = Array.prototype.slice.call(@canvas.children)
      head_pos        = canvas_els.indexOf(range_head)
      times_to_delete = @pos - head_pos
      before_caret    = @canvas.children[@pos-1]
      for [0...times_to_delete]
        @pos -= 1
        @canvas.removeChild(before_caret)
        before_caret = @canvas.children[@pos-1]

      # Clear the selection
      selection.collapse()
      true

  # Move caret left
  # @return boolean - True on success, false on error
  #----------------------------------------------------------------------
  move_left: () =>
    if @pos > 0
      previous_el = @canvas.children[@pos-1]
      @pos       -= 1
      @canvas.insertBefore(@el, previous_el)
      true
    else @error()

  # Move caret right
  # @return boolean - True on success, false on error
  #----------------------------------------------------------------------
  move_right: () =>
    # Using -2 because:
    #
    #    | _ _
    #    0 1 2
    #
    # insertBefore() should be on element 2
    if @pos <= @canvas.children.length-2
      last_pos     = @pos == @canvas.children.length-2
      next_next_el = @canvas.children[@pos+2]
      @pos        += 1

      # If we reached the end of our typing, append the caret,
      # otherwise, insert into appropriate location.
      if last_pos then @canvas.appendChild(@el)
      else             @canvas.insertBefore(@el, next_next_el)
      true
    else @error()

  # Move caret down
  #----------------------------------------------------------------------
  move_down: () =>
    left_pos = Helpers.get_left_count(@canvas, @pos)
    while @move_right()   # Account for error at end of document
      break if Helpers.get_left_count(@canvas, @pos) == 0
    for [0...left_pos]
      next_el = @canvas.children[@pos+1]
      @move_right() unless next_el and next_el.className == "newline"

  # Move caret up
  #----------------------------------------------------------------------
  move_up: () =>
    left_pos = Helpers.get_left_count(@canvas, @pos)
    if left_pos > 0        # Prevent skipping newlines
      while @move_left()   # Account for error at beginning of document
        break if Helpers.get_left_count(@canvas, @pos) == 0
    @move_left()           # Position caret at end of row above
    row_count  = Helpers.get_left_count(@canvas, @pos)
    move_count = row_count - left_pos
    if move_count > 0
      @move_left() for [0...move_count]

  # Behavior on error
  # @return boolean - False always
  #----------------------------------------------------------------------
  error: () =>
    @el.className = "caret error"
    el = @el
    setTimeout ->
      el.className = "caret"
    , 500
    false
