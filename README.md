writer
======

An iA Writer-inspired minimal writing app.

## Demo

A demo of the latest build is available here: http://nikiliu.github.io/writer/

## Purpose

This project is a Web interpretation of iA Writer's philosophy of "Keep your hands
on the keyboard and your mind in the text." Through subtle visual cues and animations,
this project aims to make writing text an enjoyable experience.

## General Approach

Browsers currently do not support the styling of I-beams within text input fields
and text areas, so the approach taken for this project was to treat a div as the
I-beam cursor as well as every typed character in the document. This allows for
not only the customization of the cursor, but also for individual letters as well.

## Implications of Approach

Because the app was designed as outlined above, all standard behavior for text
inputs are no longer available by default. A majority of this project is to redefine
and customize the behaviors that are normally standardized across platforms. This allows for a completely different user experience when using Writer.

## Development

The app is written primarily in CoffeeScript. The `coffee/` directory contains the
core of the app, and jQuery is not used. Styling is done with Compass. Compilation
and LiveReload are handled by [Guard](https://github.com/guard/guard).

