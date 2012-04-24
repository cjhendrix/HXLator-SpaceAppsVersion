uploadTemplate = require('templates/upload')

class exports.UploadView extends Backbone.View
  id: 'upload-view'
  el: '#page'

  render: ->
    $(@el).html uploadTemplate()
    return @
