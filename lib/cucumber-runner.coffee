url = require 'url'

CucumberRunnerView = require './cucumber-runner-view'

module.exports =
  activate: (state) ->
    if state?
      @lastFile = state.lastFile
      @lastLine = state.lastLine

    atom.config.setDefaults "cucumber-runner",
      command: "cucumber"

    atom.workspaceView.command 'cucumber-runner:run'         , => @run()
    atom.workspaceView.command 'cucumber-runner:run-for-line', => @runForLine()
    atom.workspaceView.command 'cucumber-runner:run-last'    , => @runLast()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, pathname} = url.parse(uriToOpen)
      console.log protocol
      return unless protocol is 'cucumber-output:'
      new CucumberRunnerView(pathname)

  cucumberRunnerView: null

  deactivate: ->
    @cucumberRunnerView.destroy()

  serialize: ->
    cucumberRunnerViewState: @cucumberRunnerView.serialize()
    lastFile: @lastFile
    lastLine: @lastLine

  openUriFor: (file, line_number) ->
    @lastFile = file
    @lastLine = line_number

    previousActivePane = atom.workspace.getActivePane()
    uri = "cucumber-output://#{file}"
    atom.workspace.open(uri, split: 'right', changeFocus: false, searchAllPanes: true).done (cucumberRunnerView) ->
      if cucumberRunnerView instanceof CucumberRunnerView
        cucumberRunnerView.run(line_number)
        previousActivePane.activate()

  runForLine: ->
    console.log "Starting runForLine..."
    editor = atom.workspace.getActiveEditor()
    console.log "Editor", editor
    return unless editor?

    cursor = editor.getCursor()
    console.log "Cursor", cursor
    line = cursor.getScreenRow()
    console.log "Line", line

    @openUriFor(editor.getPath(), line)

  runLast: ->
    return unless @lastFile?
    @openUriFor(@lastFile, @lastLine)

  run: ->
    console.log "RUN"
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    @openUriFor(editor.getPath())
