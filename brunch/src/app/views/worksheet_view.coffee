worksheetTemplate = require('templates/worksheet')

class exports.WorksheetView extends Backbone.View
  id: 'worksheet-view'
  el: '#page'
  selected_from : ''
  head_select : 0
  head_json : []
  head_from : ''
  head_to : ''
  data_json : []
  data_from : ''
  data_to : ''
  selection_done : 0


  events:
    'click td' : 'selectCell'

  render: (data) =>
    @filepath = data
    if @filepath
      do ajaxCall = =>
        $.ajax(
          url:'/fetch_rows/'
          type:'POST'
          dataType:'json'
          data:{filename:@filepath}
          success:(data)=>
            $(@el).html worksheetTemplate(data)
            return @
          error: =>
            setTimeout ajaxCall, 5000
        )

  selectCell:(event)=>
    id = event.currentTarget.id
    if @selected_from == ''
      @selected_from = id
      if @head_select == 0
        $('td').removeClass('blue')
        $('#'+id).addClass('blue')
      else
        $('td').removeClass('grey')
        $('#'+id).addClass('grey')
    else
      from = @selected_from.split('-')
      to = id.split('-')
      if @head_select == 0
        @head_from = from
        @head_to = to
      else
        @data_from = from
        @data_to = to
      imin = parseInt(from[0])
      imax = parseInt(to[0]) + 1
      jmin = parseInt(from[1])
      jmax = parseInt(to[1]) + 1
      i = imin
      while i < imax
        j = jmin
        while j < jmax
          if @head_select == 0
            $('#' + i + '-' + j).addClass 'blue'
          else
            $('#' + i + '-' + j).addClass 'grey'
          j++
        i++
      @head_select++
      @selected_from = ''
      if @head_select == 1
        alert 'You have selected the headers. Now please select the data range'
    if @head_select == 2
      result = confirm 'have you selected the correct data?'
      if result
        @create_json()
      else
        @head_select = 1

  create_json: =>
    from = @head_from
    to = @head_to
    imin = parseInt(from[0])
    imax = parseInt(to[0]) + 1
    jmin = parseInt(from[1])
    jmax = parseInt(to[1]) + 1
    i = imin
    while i < imax
      rows = []
      j = jmin
      while j < jmax
        data = $('#' + i + '-' + j).data('value')
        #sparql here to form the dictionary of headers
        rows.push(id: i+'-'+j, value:data)
        j++
      @head_json.push(rows)
      i++
    console.log @head_json
