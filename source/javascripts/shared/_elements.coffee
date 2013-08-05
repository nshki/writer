#----------------------------------------------------------------
# Elements
#----------------------------------------------------------------

class window.Elements   # Define properties and methods with @

  # Document canvas
  #----------------------------------------------------------------------
  @canvas: document.querySelector(".canvas")

  # iOS keyboard
  #----------------------------------------------------------------------
  @ios_input: document.querySelector(".ios-keyboard")

  # Menu elements
  #----------------------------------------------------------------------
  @canvas_menu:  document.querySelector(".canvas-options")
  @focus_button: document.querySelector(".focus-toggle")

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
