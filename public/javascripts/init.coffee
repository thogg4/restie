window.app = {}
app.collections = {}
app.models = {}
app.views = {}

class Window extends Backbone.View
  el: $ 'body'

  initialize: ->

    window.windowWidth = $(window).width()
    window.windowHeight = $(window).height()
    window.textHeight = windowHeight-100
    window.inCanvas = false

    @.$(".notes").css
      height: window.windowHeight-40

    @.$(".canvas").css
      width: window.windowWidth-301 #the 1px extra is for the border on canvas
      height: window.windowHeight-40

    return


class Toolbar extends Backbone.View
  el: $ '.toolbar'

  events:
    'click .new': 'callAddNote'



  callAddNote: ->
    app.views.notes_view.addNote [{title: '', body: ''}]





class Note extends Backbone.Model


class Notes extends Backbone.Collection
  model: Note
  url: 'http://0.0.0.0:4567/notes'
  initialize: ->
    @fetch
      success: (collection, response) ->
        app.views.notes_view = new NotesView(collection)



class NotesView extends Backbone.View
  el: $ '.notes'

  initialize: (collection) ->
    @collection = collection
    @collection.bind 'add', @addNote
    _.each @collection.models, (n) ->
      @addNote n
    , @

    return

  addNote: (note) ->
    note_view = new NoteView model: note
    $(@el).append note_view.render()
    return


class NoteView extends Backbone.View
  tagName: 'li'

  events:
    'click': 'openNote'

  initialize: ->

  render: ->
    $(@el).html "#{@model.attributes.title}"

  openNote: ->
    # first get a new canvas
    new CanvasView(@)
    # second, remove selected from everything
    $('.notes li.selected').removeClass('selected')
    # third, add selected to the correct one
    $(@el).addClass 'selected'
    return


class CanvasView extends Backbone.View
  tagName: 'div'

  initialize: (note) =>
    console.log @
    @note = note
    @render()

  render: =>
    console.log @
    $('.canvas').html("""
      <input type='text' value='#{@note.model.attributes.title}'>
      <div class="line"></div>
      <textarea>#{@note.model.attributes.body}</textarea>
    """).find('textarea').css
      height: window.textHeight







$ ->
  console.log "doc ready"
  app.views.window = new Window

  app.models.note = new Note
  app.views.toolbar = new Toolbar
  app.collections.notes = new Notes












