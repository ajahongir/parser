jQuery ->
  $('.datepicker').datepicker 
    minDate: new Date(),
    dateFormat: 'dd.mm.yy'
    showOn: "button",
    buttonImage: "/assets/calendar.gif",
    buttonImageOnly: true

  $('.datepicker').change ->
    load_data()


  load_data = (options)->
    options_url = $.param options if options
    $(".data-container").load '/home/search?' + $("form").serialize() + "&" + options_url

  $("form input[type='radio']").click (event) ->
    load_data(format: $(this).val())
    true

  $('form').bind 'ajax:beforeSend', (evt, data) ->
    console.log 'parse'
  $('form').bind 'ajax:success', (evt, data) -> 
    $('.data-container').html data
    console.log 'end parse'