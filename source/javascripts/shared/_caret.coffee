#------------------------------------------------------------------------
# Caret
#------------------------------------------------------------------------

class window.Caret

  pos:        0
  tab_size:   4

  # Default constructor
  # @param canvas - HTML element
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @el              = document.createElement("div")
    @el.className    = "caret"
    @el.style.height = Canvas.get_char_height(@canvas) + "px"
    @canvas.appendChild(@el)

  # Creates a new character element based on the ASCII value passed
  # @param _char - ASCII character
  #----------------------------------------------------------------------
  type: (_char) =>
    char = Caret.new_char(_char)
    @canvas.insertBefore(char, @el)
    @pos += 1

    # Allow mouse clicks within document
    char.onclick = (e) =>
      @canvas.insertBefore(@el, char)
      @recalculate_pos()

      # Place cursor to left or right of clicked character, depending on
      # click coordinates relative to character coordinates.
      offset = @canvas.offsetLeft + char.offsetLeft
      @move_right() if (offset+(char.offsetWidth/2)) < e.clientX

  # Tabs x spaces, where x is defined as an instance variable
  # @param e - Event
  #----------------------------------------------------------------------
  tab: (e) =>
    e.preventDefault()   # Prevent default element focus
    @spacebar() for [0...@tab_size]

  # Duplicate standard spacebar behavior
  # @param e - Event
  #----------------------------------------------------------------------
  spacebar: (e) =>
    e.preventDefault() if e   # Prevent default scroll with space
    @type("&nbsp;")

  # Duplicate standard return / enter behavior
  #----------------------------------------------------------------------
  enter: () =>
    @pos   += 1
    newline = Caret.new_break()
    newline.classList.add("enter")
    @canvas.insertBefore(newline, @el)

  # Delete character located left of caret
  # @param  e       - Event
  # @return boolean - True on success false on error
  #----------------------------------------------------------------------
  delete: (e) =>
    e.preventDefault()   # Prevent navigating back in browser
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
        @recalculate_pos()
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

  # Delete line
  # @param e - Event
  #----------------------------------------------------------------------
  cmd_delete: (e) =>
    e.preventDefault()
    prev_it = @canvas.children[@pos-1]
    until !prev_it or prev_it.classList.contains("newline")
      @delete(e)
      prev_it = @canvas.children[@pos-1]

  # Delete word
  # @param e - Event
  #----------------------------------------------------------------------
  alt_delete: (e) =>
    e.preventDefault()
    prev_it = @canvas.children[@pos-1]

    # Delete until we hit a valid character
    until !prev_it or (prev_it.classList.contains("character") and
                       prev_it.innerHTML != "&nbsp;")
      @delete(e)
      prev_it = @canvas.children[@pos-1]

    # Delete until we hit a space or newline
    until !prev_it or prev_it.innerHTML == "&nbsp;" or
                      prev_it.classList.contains("newline")
      @delete(e)
      prev_it = @canvas.children[@pos-1]

  # Move caret left
  # @param  e       - Event
  # @return boolean - True on success, false on error
  #----------------------------------------------------------------------
  move_left: (e) =>
    e.preventDefault() if e
    if @pos > 0
      previous_el = @canvas.children[@pos-1]
      @pos       -= 1
      @canvas.insertBefore(@el, previous_el)
      true
    else @error()

  # Move caret left to end of line
  # @param e - Event
  #----------------------------------------------------------------------
  move_cmd_left: (e) =>
    e.preventDefault()   # Prevent browser navigation
    left_pos = @get_left_count()
    @move_left() for [0...left_pos]
    @el.className = "caret"

  # Move caret left to previous word
  # @param e - Event
  #----------------------------------------------------------------------
  move_alt_left: (e) =>
    e.preventDefault()
    prev_el = @canvas.children[@pos-1]
    return if !prev_el   # Reached beginning of document

    # Move left until we hit a character
    until prev_el.innerHTML != "&nbsp;" and !prev_el.classList.contains("newline")
      @move_left()
      prev_el = @canvas.children[@pos-1]

    # Move left until we hit a space or newline
    until !prev_el or prev_el.innerHTML == "&nbsp;" or
                      prev_el.classList.contains("newline")
      @move_left()
      prev_el = @canvas.children[@pos-1]

  # Move caret right
  # @param  e       - Event
  # @return boolean - True on success, false on error
  #----------------------------------------------------------------------
  move_right: (e) =>
    # Using -2 because:
    #
    #    | _ _
    #    0 1 2
    #
    # insertBefore() should be on element 2
    e.preventDefault() if e
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

  # Move caret right to end of line
  # @param e - Event
  #----------------------------------------------------------------------
  move_cmd_right: (e) =>
    e.preventDefault()   # Prevent browser navigation
    while true
      next_el = @canvas.children[@pos+1]
      if (next_el and next_el.classList.contains("newline")) or !@move_right()
        break
    @el.className = "caret"

  # Move caret right to next word
  # @param e - Event
  #----------------------------------------------------------------------
  move_alt_right: (e) =>
    e.preventDefault()
    next_el = @canvas.children[@pos+1]
    return if !next_el   # Reached end of document

    # Move right until we hit a character
    until next_el.innerHTML != "&nbsp;" and !next_el.classList.contains("newline")
      @move_right()
      next_el = @canvas.children[@pos+1]

    # Move right until we hit a space or newline
    until !next_el or next_el.innerHTML == "&nbsp;" or
                      next_el.classList.contains("newline")
      @move_right()
      next_el = @canvas.children[@pos+1]

  # Move caret down
  # @param e - Event
  #----------------------------------------------------------------------
  move_down: (e) =>
    e.preventDefault() if e
    if !@canvas.children[@pos+1] then return @error()
    left_pos = @get_left_count()

    # Position caret to beginning of next line. Using while-break to
    # account for move error at end of document.
    while @move_right()
      break if @get_left_count() == 0

    # Move caret to original left position unless we hit a newline
    for [0...left_pos]
      next_el = @canvas.children[@pos+1]
      @move_right() unless next_el and next_el.classList.contains("newline")
    @el.className = "caret"

  # Move caret down to end of document
  # @param e - Event
  #----------------------------------------------------------------------
  move_cmd_down: (e) =>
    e.preventDefault()
    @canvas.appendChild(@el)
    @pos = @canvas.children.length-1

  # Move caret up
  # @param e - Event
  #----------------------------------------------------------------------
  move_up: (e) =>
    e.preventDefault() if e
    if !@canvas.children[@pos-1] then return @error()
    left_pos = @get_left_count()

    # Position caret to beginning of previous line. Using while-break to
    # account for move error at beginning of document. Checking if left
    # position was positive to prevent skipping newlines.
    if left_pos > 0
      while @move_left()
        break if @get_left_count() == 0
    @move_left()

    # Move caret to original left position
    line_count = @get_left_count()
    move_count = line_count - left_pos
    if move_count > 0
      @move_left() for [0...move_count]
    @el.className = "caret"

  # Move caret up to beginning of document
  # @param e - Event
  #----------------------------------------------------------------------
  move_cmd_up: (e) =>
    e.preventDefault()
    if @canvas.children.length > 1
      iterator  = 0
      first_el  = @canvas.children[iterator]
      until !first_el.classList.contains("caret")
        iterator += 1
        first_el  = @canvas.children[iterator]
      @pos      = 0
      @canvas.insertBefore(@el, first_el)

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

  # Return x, y coordinates of caret
  # @return int array - [0] => x, [1] => y
  #----------------------------------------------------------------------
  get_coords: () =>
    return [@el.offsetLeft, @el.offsetTop]

  # Get how many characters there are to the left of the caret
  # @return int - Number of characters left of caret
  #----------------------------------------------------------------------
  get_left_count: () ->
    counter = 0
    curr_el = @canvas.children[@pos-counter]
    while curr_el and !curr_el.classList.contains("newline")
      counter += 1
      curr_el  = @canvas.children[@pos-counter]
    counter - 1   # Don't count the caret

  # Recalculate the index position of the caret
  #----------------------------------------------------------------------
  recalculate_pos: () =>
    canvas_els = Array.prototype.slice.call(@canvas.children)
    @pos       = canvas_els.indexOf(@el)

  # Returns a new character element
  # @param  ascii        - ASCII character
  # @return HTML element - New DOM object
  #----------------------------------------------------------------------
  @new_char: (ascii) =>
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = ascii
    char

  # Returns a new newline element
  # @return HTML element - New DOM object
  #----------------------------------------------------------------------
  @new_break: () =>
    newline           = document.createElement("br")
    newline.className = "newline"
    newline
