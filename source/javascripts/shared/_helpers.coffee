#------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------

class window.Helpers   # Define properties and methods with @

  # Inserts break elements between words in the canvas to rid of
  # horizontal overflow.
  # @param canvas - Canvas element
  #----------------------------------------------------------------------
  @wordwrap: (canvas) =>
    chars     = 0
    max_chars = Math.floor((canvas.offsetWidth-210)/10)
    for i in [0...canvas.children.length]
      el     = canvas.children[i]
      chars += 1 if el.className == "character"
      chars  = 0 if el.className == "newline"

      # Once we count past the maximum number of characters, look back
      # to find a space.
      if chars > max_chars
        for j in [i..0] by -1

          # Once we find a space, insert a newline before and delete
          space = canvas.children[j]
          if space.innerHTML == "&nbsp;"
            canvas.insertBefore(Elements.new_break(), space)
            canvas.removeChild(space)
            chars = 0
            break

  # Adjust window scroll so that the caret is visible
  # @param canvas - Canvas element
  #        caret  - Caret object
  #----------------------------------------------------------------------
  @ensure_visible: (canvas, caret) =>
    coords   = caret.get_coords()
    vpadding = 50    # Less than .canvas padding-top + caret height

    # Offscreen top
    until coords[1] >= canvas.scrollTop+vpadding
      canvas.scrollTop -= 10
      coords            = caret.get_coords()

    # Offscreen bottom
    until coords[1]-canvas.scrollTop <= window.innerHeight-vpadding
      canvas.scrollTop += 10
      coords            = caret.get_coords()

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

  # Get how many characters there are to the left of the caret
  # @param  canvas - Document canvas
  #         pos    - Current caret position
  # @return int    - Number of characters left of caret
  #----------------------------------------------------------------------
  @get_left_count: (canvas, pos) ->
    counter = 0
    curr_el = canvas.children[pos-counter]
    while curr_el and curr_el.className != "newline"
      counter += 1
      curr_el  = canvas.children[pos-counter]
    counter - 1   # Don't count the caret

  # Get the index position of the caret
  # @param  canvas - Document canvas
  #         caret  - Caret element
  # @return int    - Index of caret
  #----------------------------------------------------------------------
  @get_caret_pos: (canvas, caret) =>
    canvas_els = Array.prototype.slice.call(canvas.children)
    canvas_els.indexOf(caret)
