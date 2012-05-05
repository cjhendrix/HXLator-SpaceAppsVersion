class exports.MainRouter extends Backbone.Router
  routes :
    'home': 'home'
    'upload' : 'upload'
    'sheet' : 'sheet'

  home: ->
    app.views.home.render()
    
  upload: ->
    app.views.upload.render()
