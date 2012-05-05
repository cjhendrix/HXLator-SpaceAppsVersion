worksheetTemplate = require('templates/worksheet')

class exports.WorksheetView extends Backbone.View
  id: 'worksheet-view'
  el: '#page'
  selected_from : ''
  data_json : []
  head_json : []
  data_from : ''
  data_to : ''
  selection_done : 0
  converted_hxl : ''
  total_data : {}


  events:
    'click td.cell' : 'selectCell'
    'change #rdf-type' : 'fill_dropdown_child'
    'click #submitme' : 'submit_hxl'

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
        @create_head_json()
      else
        @selected_from = ''

  create_head_json: =>
    from = @data_from
    to = @data_to
    imin = parseInt(from[0])
    imax = parseInt(to[0])
    jmin = parseInt(from[1])
    jmax = parseInt(to[1])
    @head_json = []
    i = 0
    while i < jmax
      selected_cell = $("#h-#{i}").val()
      @head_json.push(selected_cell)
      i++
    @create_data_json()

  create_data_json: =>
    from = @data_from
    to = @data_to
    imin = parseInt(from[0])
    imax = parseInt(to[0]) + 1
    jmin = parseInt(from[1])
    jmax = parseInt(to[1]) + 1
    i = imin
    @data_json = []
    while i < imax
      j = jmin
      now = new Date()
      id = now.getTime()
      row = {id:id, cells:[]}
      while j < jmax
        data = $('#' + i + '-' + j).data('value')
        row.cells.push(data)
        j++
      @data_json.push(row)
      i++
    @generate_total_data()

  generate_total_data:=>
    @total_data = {
                    rows:@data_json,
                    type: $('#rdf-type').val(),
                    headers:@head_json
                  }
    @process_data(@total_data)

  process_data: (data) =>
    @converted_hxl = []
    for row in data.rows
      for cell, i in row.cells
        header = data.headers[i]
        if cell != '' and header != 'ignore'
          @converted_hxl += "<#{data.type}/#{row.id}> <#{header}> #{cell} .\n"
    scrWidth = $(window).width()
    scrHeight = $(window).height()
    hxlspacing = (scrWidth - 605)/2
    hxltop = (scrHeight - 440)/2
    $('#hxlcode').val(@converted_hxl)
    $('#hxlresult').css('left',hxlspacing).css('top',hxltop)
    $('#spotlight').fadeIn('fast')
    $('#hxlresult').fadeIn('fast')
    #console.log @converted_hxl

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
    $('.child-name').append($('<option></option>').attr("value","ignore").text("--ignore this column"))
    for value in hxl_attribute
      display_label = hxl_labels[value]
      display_value = value
      $('.child-name').append($("<option></option>").attr("value",display_value).text(display_label))
  
  submit_hxl:(event) =>
    event.preventDefault()
    dosubmit = confirm 'do you wish to submit the HXL data to the data repository?'
    if dosubmit
      $('#submitform').submit()
      alert 'Your HXL data has been submitted. Thank your for contributing'
      location.hash = 'home'#  isoDateString:(d)=>
#    pad (n) =>
#      if n < 10 
#        return '0'+n
#      else 
#        return n
#    return d.getUTCFullYear()+'-'+ d.getUTCFullYear()+'-'+ pad(d.getUTCMonth()+1)+'-'+ pad(d.getUTCDate())+'T'+ pad(d.getUTCHours())+':'+ pad(d.getUTCMinutes())+':'+ pad(d.getUTCSeconds())+'Z'

# returns an object that describes a the range of a selection
# the arguments must of the form '0-1', '0-2', etc...
#  selection_range : (from_id, to_id) =>
#    from = from_id.split('-')
#    to = to_id.split('-')
#    rowmin : Math.min(parseInt(from[0],10),parseInt(to[0],10))
#    rowmax:  Math.max(parseInt(from[0],10),parseInt(to[0],10))
#	   colmin: Math.min(parseInt(from[1],10),parseInt(to[1],10))
#	   colmax:  Math.max(parseInt(from[1],10),parseInt(to[1],10))

# reads the data from the table
# and returns it in the format accepted by data_to_hxl
# the headers must be select fields with ids like h-0, h-1, etc...
# the cells (td) must have ids like 0-1, 0-2, etc...
# and an attribute data-value
# the arguments must be of the same form as cell ids '0-1' etc..
#  selected_data : (selected_from, selected_to) =>
#    range = selection_range(selected_from, selected_to)

#    headers = []
#    skipped = []
#    for j in [range.colmin..range.colmax]
#      selected = $("#h-#{j}").val() # a select field
#      skip = (selected == "ignore")
#      skipped.push(skip)
#      headers.push(selected) unless skip


#    data = {
#          rows: rows,
#          type: $('#rdf-type').val(), # a select field
#          headers: headers }


  


# test data in the format that data_to_hxl accepts
#  test_data: =>
#    {
#    type: 'affectedPopulation',
#    headers: ['location','rope','tents'],
#    rows: [{
#          id: 1234,
#          cells: ['dubai',50, 10]},
#          {
#          id: 14567,
#          cells: ['new york', 40, 9]}]}

