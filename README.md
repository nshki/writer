writer
======

An iA Writer-inspired minimal writing app.

## Demo

A demo of the latest build is available here: http://nikiliu.github.io/writer/

## General Approach

Browsers currently do not support the styling of I-beams within text input fields
and text areas, so the approach taken for this project was to treat a div as the
I-beam cursor as well as every typed character in the document. This allows for
not only the customization of the cursor, but also for individual letters as well.

## Implications of Approach

Because the app was designed as outlined above, all standard behavior for text
inputs are no longer available by default. A majority of this project is to redefine
and customize the behaviors that are normally available by default. These include:

  - Backspace
  - Enter / return
  - Tab
  - Delete selection
  - Paste text
  - etc...
 
## Development

The app is written primarily in CoffeeScript. The `coffee/` directory contains the
core of the app. `_base.coffee` contains classes and general code that is executed
in `main.coffee`. Styling is done with Compass. Compilation and LiveReload are
handled by [Guard](https://github.com/guard/guard).
