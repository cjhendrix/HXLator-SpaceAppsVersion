homeTemplate = require('templates/home')

class exports.HomeView extends Backbone.View
  id: 'home-view'
  el: '#page'

  render: ->
    $(@el).html homeTemplate()
    return @
