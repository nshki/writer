#------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------

class window.Helpers   # Define properties and methods with @

  # Identifies current sentence/line and highlight it
  # @param canvas - Canvas element
  #        pos    - Caret integer position
  #----------------------------------------------------------------------
  @focus_mode: (canvas, pos) =>
    delimiters = [".", "!", "?"]

    # Clear all current elements
    el.classList.remove("current") for el in canvas.children

    # Find end of previous sentence
    end_first = false
    until !canvas.children[pos-1]
      for delimiter in delimiters
        if canvas.children[pos-1].innerHTML == delimiter
          end_first = true
          break
      break if end_first
      pos -= 1

    # Mark every character till next delimiter
    end_last = false
    until !canvas.children[pos]
      for delimiter in delimiters
        if canvas.children[pos].innerHTML == delimiter
          end_last = true
          break
      if !canvas.children[pos].classList.contains("caret")
        canvas.children[pos].classList.add("current")
      break if end_last
      pos += 1

  # Inserts break elements between words in the canvas to rid of
  # horizontal overflow.
  # @param canvas - Canvas element
  #----------------------------------------------------------------------
  @wordwrap: (canvas) =>
    chars     = 0
    max_chars = Math.floor((canvas.offsetWidth-110)/10)
    for i in [0...canvas.children.length]
      el     = canvas.children[i]
      chars += 1 if el.className == "character"
      chars  = 0 if el.classList.contains("enter")

      # Remove any newlines that weren't manually entered
      if el.className == "newline"
        canvas.insertBefore(Elements.new_char("&nbsp;"), el)
        canvas.removeChild(el)

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
    until coords[1]-canvas.scrollTop <= canvas.offsetHeight-vpadding
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
    while curr_el and !curr_el.classList.contains("newline")
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
