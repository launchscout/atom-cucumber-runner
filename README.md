# Atom Cucumber Runner Package

----

Total rip-off of the atom-rspec package, but runs cucumber instead. I should
refactor the common bits out, but for now I just wanted something working. I'm
lazy like that, which isn't really the good kind of lazy. *Sigh*

-----

Add ability to run Cucumber and see the output without leaving Atom.

HotKeys:

- __alt+cmd+k__ - executes current feature file
- __ctrl+cmd+__ - executes only the cuke on the line the cursor's at
- __ctrl+alt+k__ - re-executes the last executed cuke

## Configuration

By default this package will run `cucumber` as the command.

You can set the default command by either accessing the Settings page (Cmd+,)
and changing the command option like below:

![Configuration Screenshot](http://f.cl.ly/items/0V0w3U2M450g0p2q1g1r/Fullscreen_5_12_14__22_10.png)

Or by opening your configuration file (clicking __Atom__ > __Open Your Config__)
and adding or changing the following snippet:

    'cucumber':
      'command': 'bundle exec cucumber'
