![Sauce](source/images/sauce.png?raw=true)

## Overview

[Middleman](http://middlemanapp.com/) template with Haml, Compass, CoffeeScript,
and DRY file structure. Comes ready with IE conditional classes, HTML5Shiv, body
classes, jQuery (official CDN), LiveReload, and pretty URLs.


## Installing / Updating

    # Clone the repo as a Middleman template
    git clone git@github.com:nikiliu/sauce.git ~/.middleman/sauce

    # Update to latest version
    cd ~/.middleman/sauce/; git pull


## Usage

    # Scaffold a project using Sauce
    middleman init [my_project] --template=sauce

    # Optionally remove default README and Git repository
    cd ~/.middleman/sauce/; rm -rf README .git/

    # Fire up a local development server (LiveReload equipped)
    bundle exec middleman server

    # Build a production-ready version of your app
    bundle exec middleman build


## File Structure

    |_ source/
    |  |_ images/
    |  |  |_ sauce.png             # Sauce logo
    |  |
    |  |_ javascripts/
    |  |  |_ shared/
    |  |  |  |_ _elements.coffee   # "Module" containing reusable elements
    |  |  |  |_ _helpers.coffee    # "Module" containing helper functions
    |  |  |
    |  |  |_ vendor/               # For any third-party plugins
    |  |  |
    |  |  |_ _main.coffee          # Main JavaScript functionality
    |  |  |_ application.coffee    # Imports all scripts
    |  |
    |  |_ layouts/
    |  |  |_ _doctype.haml         # Partial containing DOCTYPE and IE conditional classes
    |  |  |_ _icons.haml           # Partial containing application icons
    |  |  |_ _meta.haml            # Partial containing meta tags
    |  |  |_ main.haml             # Main layout
    |  |
    |  |_ stylesheets/
    |  |  |_ shared/
    |  |  |  |_ _colors.sass       # Color definitions
    |  |  |  |_ _fonts.sass        # Font definitions
    |  |  |  |_ _ie.sass           # IE styles
    |  |  |  |_ _media.sass        # Media queries
    |  |  |  |_ _mixins.sass       # Custom mixins
    |  |  |  |_ _variables.sass    # General variables
    |  |  |
    |  |  |_ vendor/
    |  |  |  |_ normalize.css      # Normalize v2.1.2
    |  |  |
    |  |  |_ _main.sass            # Main app styles
    |  |  |_ application.sass      # Imports Compass and all stylesheets
    |  |
    |  |_ favicon.ico              # Sauce favicon
    |  |_ index.html               # Homepage
    |
    |_ .gitignore                  # Git ignore
    |_ config.rb                   # Middleman configuration
    |_ Gemfile                     # Dependencies
    |_ Gemfile.lock                # Last verified dependencies
    |_ README.md                   # This README


## Adding New Pages

To create a new page, simply create a new `.haml` file in the `source/` directory. The
default `index.haml` begins with the following lines:

    ---
    title:   Welcome to Sauce
    layout:  main
    classes: home
    ---

`title` gets translated directly to the `<title>` tag in the layout, `layout` selects
which layout to use for the page, and `classes` is a list of classes, separated by a
space, the `<body>` tag will have.

Sauce utilizes Middleman's pretty URL plugin, which will convert every new page file to
have its own pretty URL. Example: `newpage.haml` can be seen at `/newpage`.


## CoffeeScript "Modules"

CoffeeScript does not support Ruby-esque modules out of the box. Furthermore, writing
code to be reused across multiple `.coffee` files fails because of the automatic
insertion of anonymous function wrappers by the compiler.

To get around this problem, Sauce defines external "modules" as window-level classes.
By defining properties and methods using the `@` character, they become class-level,
globally accessible, namespaced entities.

Example:

    ---
    _elements.coffee
    ---
    class window.Elements
      @myelement: "Hello World!"

    ---
    _helpers.coffee
    ---
    class window.Helpers
      @mymethod: () ->
        console.log Elements.myelement

    ---
    _main.coffee
    ---
    Helpers.mymethod()   # Prints "Hello World!"

This keeps the organization of scripts cleaner and easier to maintain without clobbering
the global namespace.
