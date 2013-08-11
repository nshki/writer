writer
======

An iA Writer-inspired writing app. http://nikiliu.github.io/writer/


## Purpose

This project was a personal programming challenge -- after realizing
there is no streamlined way of styling a caret (or I-beam) in an input
area, why not implement a brand new one? The caret has potential to be
a much more polished visual tool for a user. It could have subtle
animations on illegal moves, it could blink in different ways, it
could (insert imagination here), all while staying unobtrusive.


## Approach

The approach that this project is based on is that every typed
character is its own DOM element. This means that every keystroke is
wrapped in either a `<div>` or `<span>`. Inherently, this approach has
negative impacts on performance, however, it opens many interesting
doors by having granular control over a document.

This approach also means that common, taken-for-granted functionality has
to be reprogrammed. This includes features such as moving a cursor around
using arrow keys, keyboard shortcuts for navigation, copy/cut/paste, word
wrap, and etc.


## Development

Writer is built on [Middleman](http://middlemanapp.com/) and the
[Sauce](http://github.com/nikiliu/sauce/) Middleman template. All of
the functionality is written in [CoffeeScript](http://coffeescript.org/).

The main files to look at are [_canvas.coffee](https://github.com/nikiliu/writer/blob/master/source/javascripts/shared/_canvas.coffee)
and [_caret.coffee](https://github.com/nikiliu/writer/blob/master/source/javascripts/shared/_caret.coffee).
