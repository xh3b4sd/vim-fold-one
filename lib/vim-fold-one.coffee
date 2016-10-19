{CompositeDisposable} = require 'atom'
{Point} = require 'atom'

module.exports = VimFoldOne =
  editor: null
  currentRow: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor', 'vim-fold-one:move-up', => @moveUp()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'vim-fold-one:move-down', => @moveDown()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'vim-fold-one:toggle-current-fold', => @toggleCurrentFold()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'vim-fold-one:toggle-all-folds', => @toggleAllFolds()

  deactivate: ->
    @subscriptions.dispose()

  toggleCurrentFold: ->
    @editor = atom.workspace.getActiveTextEditor()
    @currentRow = @editor.bufferPositionForScreenPosition(@editor.getCursorScreenPosition()).row
    return if not @editor

    foldableRows = []

    currentIndentation = @getIndent(@currentRow)
    nextIndentation = @getIndent(@currentRow+1)
    if currentIndentation == 0 and nextIndentation > currentIndentation
      foldableRows = @foldableRowsFromStart(@currentRow)
    else
      foldableRows = @foldableRowsFromBody(@currentRow)

    isFolded = @editor.isFoldedAtBufferRow(@currentRow)
    for row in foldableRows
      if isFolded
        @editor.unfoldBufferRow(row)
      else
        @editor.foldBufferRow(row)

  toggleAllFolds: ->
    @editor = atom.workspace.getActiveTextEditor()
    @currentRow = @editor.bufferPositionForScreenPosition(@editor.getCursorScreenPosition()).row
    return if not @editor

    if @editor.isFoldedAtBufferRow(@currentRow)
      @editor.unfoldAll()
    else
      @editor.foldAll()

  foldableRowsFromBody: (row) ->
    return @foldableRowsFromBodyUpwards(row).concat(@foldableRowsFromBodyDownwards(row++))

  foldableRowsFromBodyUpwards: (row) ->
    foldableRows = [row]
    loop
      row--
      return foldableRows if @getIndent(row) is 0
      foldableRows.push(row)

  foldableRowsFromBodyDownwards: (row) ->
    foldableRows = [row]
    loop
      row++
      return foldableRows if @getIndent(row) is 0
      foldableRows.push(row)

  foldableRowsFromStart: (row) ->
    foldableRows = [row]
    startIndentation = @getIndent(row)
    loop
      row++
      return foldableRows if @getIndent(row) is startIndentation
      foldableRows.push(row)

  moveUp: ->
    @editor = atom.workspace.getActiveTextEditor()
    @currentRow = @editor.bufferPositionForScreenPosition(@editor.getCursorScreenPosition()).row
    return if not @editor

    lastIndentation = null
    row = @currentRow

    loop
      # The row above us might be zero or even negative. In case we reached
      # the top of the file, stop here.
      row--
      return if row <= 0

      indentation = @getIndent row
      break if indentation is 0 and lastIndentation? and lastIndentation > 0

      lastIndentation = indentation

    @editor.setCursorBufferPosition(new Point(row, 0))

  moveDown: ->
    @editor = atom.workspace.getActiveTextEditor()
    @currentRow = @editor.bufferPositionForScreenPosition(@editor.getCursorScreenPosition()).row
    return if not @editor

    lastIndentation = null
    row = @currentRow

    loop
      # The row below us might be the last one of the file. In case we reached
      # the end of the file, stop here.
      row++
      return if row >= @editor.getLineCount()

      indentation = @getIndent row
      break if indentation is 0 and lastIndentation? and lastIndentation <= 0 and @getIndent(row+1) > indentation

      lastIndentation = indentation

    @editor.setCursorBufferPosition(new Point(row, 0))

  getIndent: (row) ->
    lineText = @editor.lineTextForBufferRow(row)
    return -1 if not lineText or lineText is ""
    if lineText.match(/^\s*$/)
      0
    else
      @editor.indentationForBufferRow(row)
