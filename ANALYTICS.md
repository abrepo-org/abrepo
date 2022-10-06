# Google Analytics / Tag Manager Setup

0. Create Analytics, Tag Manager Properties

The account is quirkshop llc, the property / container is ABrepo.

1. Setup additional Tag Manager environments

These have slightly different snippets, set in app according to ENV.

GTM: `Admin` -> `Environments` -> `Actions` -> `Get Snippet`

* Dev
* Staging

2. Tag Manager interaction with GA4

a. Add Tag: "GA4 Configuration", set Measurement ID according to GA4
setup (G-xxxxx..0)

b. Trigger: All Pages


3. Tag Manager: add Environment event

a. `Variables` -> `New` -> `Utilities` -> save

Add that 'event' to Tag

b. `Tags` -> `New` -> `GA4 Event`; will see `Environment` as newly
available variable.

c. Configure event:

  * Event Name: `environmnet_name` (looks like convention)
  * Event Parameters: "Environment Name"
  * Value : {{Environment Name}}

d. Trigger on page views


4. TODO: Google Analytics, filtering report according to environment

Trying:
1. Create a trigger (Environment name is Dev)
2. Create tag with `debug_mode` = `true` parameter that uses above trigger
