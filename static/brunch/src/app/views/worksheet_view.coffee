worksheetTemplate = require('templates/worksheet')

class exports.WorksheetView extends Backbone.View
  id: 'worksheet-view'
  el: '#page'
  selected_from : ''
  data_json : []
  data_from : ''
  data_to : ''
  selection_done : 0


  events:
    'click td.cell' : 'selectCell'
    'change #rdf-type' : 'fill_dropdown_child'

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
            @fill_dropdown_head()
            return @
          error: =>
            setTimeout ajaxCall, 5000
        )

  selectCell:(event)=>
    id = event.currentTarget.id
    if @selected_from == ''
      @selected_from = id
      $('td').removeClass('grey')
      $('#'+id).addClass('grey')
    else
      from = @selected_from.split('-')
      to = id.split('-')
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
          $('#' + i + '-' + j).addClass 'grey'
          j++
        i++
      @selected_from = ''
      result = confirm 'have you selected the correct data?'
      if result
        @create_json()
      else
        @selected_from = ''

  create_json: =>
    from = @data_from
    to = @data_to
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
      @data_json.push(rows)
      i++
    console.log @data_json

  fill_dropdown_head:=>
    hxl_type = app.hxl.hxltypes
    hxl_labels = app.hxl.hxllabels
    for key,value of hxl_type
      display_label = hxl_labels[key]
      display_value = key
      $('#rdf-type').append($("<option></option>").attr("value",display_value).text(display_label))

  fill_dropdown_child:=>
    parentnode = $('#rdf-type').val()
    hxl_labels = app.hxl.hxllabels
    hxl_attribute = app.hxl.hxltypes[parentnode].attributes
    $('th > select.child-name > option').remove()
    for value in hxl_attribute
      display_label = hxl_labels[value]
      display_value = value
      $('.child-name').append($("<option></option>").attr("value",display_value).text(display_label))

