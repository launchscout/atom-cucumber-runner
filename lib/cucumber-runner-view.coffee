{$, $$$, EditorView, ScrollView} = require 'atom'
ChildProcess = require 'child_process'
path = require 'path'

module.exports =
class CucumberRunnerView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new CucumberRunnerView(filePath)

  @content: ->
    @div class: 'cucumber', tabindex: -1, =>
      @div class: 'cucumber-spinner', 'Starting Cucumber...'
      @pre class: 'cucumber-output'

  constructor: (filePath) ->
    super
    console.log "File path:", filePath
    @filePath = filePath

    @output = @find(".cucumber-output")
    @spinner = @find(".cucumber-spinner")
    @output.on("click", @terminalClicked)

  serialize: ->
    deserializer: 'CucumberRunnerView'
    filePath: @getPath()

  destroy: ->
    @unsubscribe()

  getTitle: ->
    "Cucumber - #{path.basename(@getPath())}"

  getUri: ->
    "cucumber-output://#{@getPath()}"

  getPath: ->
    @filePath

  showError: (result) ->
    failureMessage = "The error message"

    @html $$$ ->
      @h2 'Running Cucumber Failed'
      @h3 failureMessage if failureMessage?

  terminalClicked: (e) =>
    if e.target?.href
      line = $(e.target).data('line')
      file = $(e.target).data('file')
      console.log(file)
      file = "#{atom.project.getPath()}/#{file}"

      promise = atom.workspace.open(file, { searchAllPanes: true, initialLine: line })
      promise.done (editor) ->
        editor.setCursorBufferPosition([line-1, 0])

  run: (line_number) ->
    @spinner.show()
    @output.empty()
    project_path = atom.project.getRootDirectory().getPath()

    spawn = ChildProcess.spawn

    specCommand = atom.config.get("cucumber-runner.command")
    command = "#{specCommand} #{@filePath}"
    command = "#{command} -l #{line_number + 1}" if line_number

    console.log "[Cucumber] running: #{command}"

    terminal = spawn("bash", ["-c", "cd #{project_path} && #{command}\n"])

    terminal.on 'close', @onClose

    terminal.stdout.on 'data', @onStdOut
    terminal.stderr.on 'data', @onStdErr


  addOutput: (output) =>

    output = "#{output}"
    output = output.replace /([^\s]*:[0-9]+)/g, (match) ->
      file = match.split(":")[0]
      line = match.split(":")[1]
      "<a href='#{file}' data-line='#{line}' data-file='#{file}'>#{match}</a>"

    @spinner.hide()
    @output.append("#{output}")
    @scrollTop(@[0].scrollHeight)

  onStdOut: (data) =>
    @addOutput data

  onStdErr: (data) =>
    @addOutput data

  onClose: (code) =>
    console.log "[Cucumber] exit with code: #{code}"
