#------------------------------------------------------------------------
# Caret controls the behavior of the blinking I-beam. Any typing or
# action keys / shortcuts respond to the methods defined by this class.
#------------------------------------------------------------------------
class window.Caret

  pos:      0
  tab_size: 4

  # Default constructor
  #----------------------------------------------------------------------
  constructor: (@canvas) ->
    @el              = document.createElement("div")
    @el.className    = "caret"
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

  # Delete character located left of caret
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
      else @error()
    else
      range      = selection.getRangeAt(0)
      range_head = range.startContainer.parentNode
      range_tail = range.endContainer.parentNode

      # If the caret is not at the end of the selection, position the
      # caret so that it is.
      if range_tail != @canvas
        @canvas.insertBefore(@el, range_tail)
        @pos = @get_caret_pos()
        @move_right()

      # Delete until the selection is gone
      canvas_els      = Array.prototype.slice.call(@canvas.children)
      head_pos        = canvas_els.indexOf(range_head)
      times_to_delete = @pos - head_pos
      before_caret    = @canvas.children[@pos-1]
      for i in [1..times_to_delete]
        @pos -= 1
        @canvas.removeChild(before_caret)
        before_caret = @canvas.children[@pos-1]

      # Clear the selection
      selection.collapse()

  # Move caret left
  #----------------------------------------------------------------------
  move_left: () =>
    window.getSelection().collapse()
    if @pos > 0
      previous_el = @canvas.children[@pos-1]
      @pos       -= 1
      @canvas.insertBefore(@el, previous_el)
    else @error()

  # Move caret right
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

      # If we reached the end of our typing, append the caret,
      # otherwise, insert into appropriate location.
      if last_pos then @canvas.appendChild(@el)
      else             @canvas.insertBefore(@el, next_next_el)
    else @error()

  # Move caret down
  #----------------------------------------------------------------------
  move_down: () =>
    # The first element* is the caret itself, the second element* is the
    # character that the caret is on, and the third element is the
    # element we need to jump to.
    #
    # * Necessary to define "first element," as caret can be on
    #   different lines. Defined as base_index below.
    #
    # * There is one exception to the second element being the character
    #   the caret is on, and this is when the caret is at the end of
    #   a line.
    window.getSelection().collapse()
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)

    # If there is a next element, execute the if. Otherwise, move the
    # caret to the end.
    if col_els[base_index+1]

      # Define low_el to be the next element while handling the special
      # case.
      low_el = col_els[base_index+1]
      low_el = col_els[base_index+2] if col_els[base_index+2]

      # If the next element is more than two rows down, move the
      # caret to the next newline. Otherwise, move down normally.
      if low_el.offsetTop > (@el.offsetTop + @el.offsetHeight)
        caret_pos = @pos
        until @canvas.children[caret_pos].className == "newline"
          caret_pos += 1
        @canvas.insertBefore(@el, @canvas.children[caret_pos+1])

      # Move down normally. If at the last row, move to end.
      else
        if low_el.offsetTop == @el.offsetTop
          @canvas.appendChild(@el)
        else
          @canvas.insertBefore(@el, low_el)

    # Move the caret to the end. If there is no end, error.
    else
      if @pos < @canvas.children.length-1
        @canvas.appendChild(@el)
      else @error()

    @pos = @get_caret_pos()

  # Move caret up
  #----------------------------------------------------------------------
  move_up: () =>
    # The element directly before the caret in the new array is the
    # element we need to jump to.
    window.getSelection().collapse()
    col_els    = @get_col_els()
    base_index = col_els.indexOf(@el)

    # If there is an element directly above the caret, execute the if
    # branch. Otherwise, move the caret to the beginning.
    if col_els[base_index-1]

      # If the element before the caret is more than one row higher
      # than the caret, move the caret to the end of the next highest
      # row. Otherwise, move the caret up normally.
      high_el = col_els[base_index-1]
      if high_el.offsetTop < (@el.offsetTop - @el.offsetHeight)

        # Calculate position of the closest newline before the caret
        # and place the caret before it.
        caret_pos = @pos
        until @canvas.children[caret_pos].className == "newline"
          caret_pos -= 1
        @canvas.insertBefore(@el, @canvas.children[caret_pos])

      # Move caret up normally
      else @canvas.insertBefore(@el, col_els[base_index-1])

    # Move caret to the beginning. If there is no beginning, error.
    else
      if @pos > 0
        @canvas.insertBefore(@el, @canvas.children[0])
      else @error()

    @pos = @get_caret_pos()

  # Behavior on error
  #----------------------------------------------------------------------
  error: () =>
    @el.className = "caret error"
    el = @el
    setTimeout ->
      el.className = "caret"
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
  # elements that have the same left offset as the caret.
  #----------------------------------------------------------------------
  get_col_els: () =>
    col_els  = []
    col_left = @el.offsetLeft
    for el in @canvas.children
      col_els.push(el) if el.offsetLeft == col_left
    col_els

  # Helper for move_down() and move_up(). Convert an HTMLCollection
  # object to array and return the position of the caret.
  #----------------------------------------------------------------------
  get_caret_pos: () =>
    canvas_els = Array.prototype.slice.call(@canvas.children)
    canvas_els.indexOf(@el)
