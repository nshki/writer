writer
======

An iA Writer-inspired writing app. http://nikiliu.github.io/writer/


## Purpose

This project was a personal programming challenge -- after realizing
there is no streamlined way of styling a caret (or I-beam) in an input
area, I wanted to try implementing a textarea from scratch.


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
