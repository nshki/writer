#========================================================================
# _base.coffee
#========================================================================

#------------------------------------------------------------------------
# Constants
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# Classes
#------------------------------------------------------------------------
class Cursor
  # Default constructor
  constructor: (@el) ->
    @el.style.top     = "50px"    # mirror .canvas padding-top
    @el.style.left    = "100px"   # mirror .canvas padding-left
    @pos              = 0
    @char_count       = 0
    window.onkeydown  = @keydown_listener
    window.onkeypress = @keypress_listener

  # Setter methods to link DOM elements
  set_canvas:       (@canvas)       ->
  set_char_counter: (@char_counter) ->

  # Move cursor left
  move_left: (dist) =>
    new_left       = parseInt(@el.style.left) - dist
    @el.style.left = new_left + "px"
    @pos -= 1

  # Move cursor right
  move_right: (dist) =>
    new_left       = parseInt(@el.style.left) + dist
    @el.style.left = new_left + "px"
    @pos += 1

  # Increment character count
  inc_char_count: () =>
    @char_count += 1
    @char_counter.innerHTML = @char_count

  # Decrement character count
  dec_char_count: () =>
    @char_count -= 1
    @char_counter.innerHTML = @char_count

  # Behavior on error
  error: () =>
    @el.className = "cursor error"
    el = @el
    setTimeout ->
      el.className = "cursor"
    , 500

  # Handle action keys
  keydown_listener: (e) =>
    switch e.which
      # Backspace (also disable backspace navigation)
      when 8
        e.preventDefault()
        before_cursor = @canvas.children[@pos-1]

        # Handle illegal backspace
        if before_cursor
          @move_left(before_cursor.offsetWidth)
          @canvas.removeChild(before_cursor)
          @dec_char_count()
        else @error()

      # Left arrow
      when 37
        if @pos > 0
          previous_el = @canvas.children[@pos-1]
          @move_left(previous_el.offsetWidth)
          @canvas.removeChild(@el)
          @canvas.insertBefore(@el, previous_el)
        else @error()

      # Right arrow
      when 39
        if @pos <= @canvas.children.length-2
          last_pos     = @pos == @canvas.children.length-2
          next_el      = @canvas.children[@pos+1]
          next_next_el = @canvas.children[@pos+2]
          @move_right(next_el.offsetWidth)
          @canvas.removeChild(@el)

          # If we reached the end of our typing, append the cursor,
          # otherwise, insert into appropriate location.
          if last_pos @canvas.appendChild(@el)
          else        @canvas.insertBefore(@el, next_next_el)
        else @error()

  # Handle typed characters
  keypress_listener: (e) =>
    char           = document.createElement("div")
    char.className = "character"
    char.innerHTML = String.fromCharCode(e.which)
    char.innerHTML = "&nbsp;" if char.innerHTML == " "
    @canvas.insertBefore(char, @el)
    @move_right(char.offsetWidth)
    @inc_char_count()

#========================================================================
# main.coffee
#========================================================================

#------------------------------------------------------------------------
# Get DOM elements and instantiate new Cursor object
#------------------------------------------------------------------------
canvas       = document.querySelector(".canvas")
char_counter = document.querySelector(".char-counter")
cursor       = document.querySelector(".cursor")
cursor       = new Cursor(cursor)
cursor.set_canvas(canvas)
cursor.set_char_counter(char_counter)