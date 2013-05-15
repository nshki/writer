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
