# Rails Assets

Assets are compiled at build and placed into `/public`.

These are served by nginx.

## Rails Sprokets -> Webpack

Commands:

* `rails g webpacker:install`
* `rails g webpacker:install:react`

Move asset directories:

* app/assets/javascript -> app/javascript/packs
* app/assets/stylesheets -> /app/javascript/stylesheets/
* app/assets/images/  -> app/javascript/images
* app/assets: basically becomes empty directory

Change vews/layouts/application.html.erb to reference load pack tags:

* stylesheet_tag --> stylesheet_pack_tag
* javascript_tag --> javascript_pack_tag

Change assets (scss, images) to be packed in `/javscript/packs/application.js`:

```
# scss
import "../stylesheets/application.scss"

# static images
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

# .jsx - relative path is important
import "./hello_react.jsx"
import Hello from "./hello_react.jsx"

```


```
#javascript/packs/application.js
import "../stylesheets/application.scss"

#application.scss:
#example of loading module
import "body.scss"

```

```
(sudo) rake tmp:cache:clear
```

