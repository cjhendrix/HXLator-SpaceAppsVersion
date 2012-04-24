worksheetTemplate = require('templates/worksheet')

class exports.WorksheetView extends Backbone.View
  id: 'worksheet-view'
  el: '#page'

  render: ->
    $(@el).html worksheetTemplate()
    return @
