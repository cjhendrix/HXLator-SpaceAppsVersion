uploadTemplate = require('templates/upload')

class exports.UploadView extends Backbone.View
  id: 'upload-view'
  el: '#page'

  events:
    'click #uploadme' : 'do_upload'

  render: ->
    $(@el).html uploadTemplate()
    return @

  do_upload:(event)=>
    event.preventDefault()
    fullpath = $('[name=file]').val()
    if fullpath != ''
      $('#upload-form').submit()
      $('#upload-view').hide()
      $('#upload-await').show()
      app.views.worksheet.render(fullpath)
    else
      alert 'please select a file'

