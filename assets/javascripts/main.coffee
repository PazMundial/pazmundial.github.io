---
---

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Method to get value from params
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
$.urlParam = (name, fallback = null) ->
  results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href)
  return fallback unless results
  decodeURIComponent(results[1]) or fallback

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Method to get value from params
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
autoselectTz = ->
  option_to_select = $.urlParam('tz', 'Europe/Madrid')
  $('#tz').val(option_to_select).change();

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Method: on change input/select will submit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
on_change_submit = ->
  $('[data-behaviour~=on-change-submit]').one 'change', (e) ->
    e.preventDefault()
    e.stopPropagation()

    $this = $(this)
    $form = $this.closest 'form'
    $form.submit()
    return
  return

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Method to load google client.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
loadGoogleClient = (google_api_key) ->
  gapi.client.setApiKey google_api_key
  gapi.client.load('https://content.googleapis.com/discovery/v1/apis/sheets/v4/rest').then (->
    console.log 'GAPI client loaded for API'
    return
  ), (error) ->
    console.error 'Error loading GAPI client for API'
    return


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Method to load data of a google spreadsheets.
# NOTE: Make sure the google client is loaded before calling this method.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
loadDataOfGoogleSpreadsheets = (spreadsheetId) ->
  gapi.client.sheets.spreadsheets.values.batchGet(
    'spreadsheetId': spreadsheetId
    'majorDimension': 'ROWS'
    'ranges': [ 'B4:I243' ]
    'valueRenderOption': 'FORMATTED_VALUE'
  ).then ((response) ->
    # console.log 'Response', response
    current_range = response.result.valueRanges.filter (range) ->
      range.range == 'Maraton2018!B4:I243'

    $carusel = $('.owl-carousel')
    event_date_cet = ''

    console.log 'Filling data...'
    current_range[0].values.forEach (row) ->
      event_date_cet = row[0] if row[0] != ''
      event_time_cet = row[1]
      host_name = row[3]
      return unless host_name?

      youtube_broadcast_id = row[7]
      return unless youtube_broadcast_id?

      event_datetime_formated =
        moment(event_date_cet + ' ' + event_time_cet + ' +1:00', 'DD/MM/YYYY HH:mm Z', 'es')
          .tz($.urlParam('tz', 'Europe/Madrid'))
          .format('DD/MM/YYYY HH:mm z')

      international_datetime_link = row[4]
      participate_link = row[5]
      youtube_channel_link = row[6]

      $carusel.append(
        """
        <div class="item item-video event">
          <div class="row event-details margin-10">
            <div class="col-sm-6 text-left">
              <span class="event-host-name">Dirigido por #{host_name}</span>
              #{
                if youtube_channel_link != ''
                  """
                  <a class="event-host-youtube-channel" href="#{youtube_channel_link}" target="_blank">
                    <i class="fa fa-youtube"></i>
                  </a>
                  """
                else
                  ''
              }
            </div>
            <div class="col-sm-6 text-right">
              <span class="event-time-cet">#{event_datetime_formated}</span>
              #{
                if international_datetime_link != ''
                  """
                  [<a  class="event-time-international btn btn-sm" href="#{international_datetime_link}" target="_blank">
                    international time
                  </a>]
                  """
                else
                  ''
              }
            </div>
          </div>
          <div class="row margin-20">
            <div class="col-sm-12">
              <a class="owl-video" href="https://www.youtube.com/watch?v=#{youtube_broadcast_id}"></a>
            </div>
          </div>
          #{
            if participate_link? && participate_link != ''
              '<div class="row event-video">
                <div class="col-sm-12 text-center">
                  <a href="participate_link" class="btn btn-primary btn-lg" target="_blank">Participa</a>
                </div>
              </div>'
            else
             ''
          }
        </div>
        """
      )
      return


    console.log '...load owl carousel'
    $('.owl-carousel').owlCarousel
      center: true
      items: 1
      lazyLoad: true
      loop: false
      # autoWidth: true
      margin: 0
      video: true
      videoHeight: 480
      nav: true
      navText: ['anterior', 'siguente']
      dots: false
      responsiveClass: true
    return
  ), (error) ->
    console.error 'Execute error', error
    return

$(document).ready ->

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Navbar
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  menu = $('.navbar')
  $(window).bind 'scroll', (e) ->
    if $(window).scrollTop() > 140
      if !menu.hasClass('open')
        menu.addClass 'open'
    else
      if menu.hasClass('open')
        menu.removeClass 'open'
    return

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Scroll To
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  $('.scroll').click (event) ->
    event.preventDefault()
    $('html,body').animate { scrollTop: $(@hash).offset().top }, 800
    return

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # WOW Animation
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  wow = new WOW(
    boxClass: 'wow'
    animateClass: 'animated'
    offset: 0
    mobile: false)
  wow.init()

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Autoselect option of TZ select by tz param
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  autoselectTz()

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # On change select will submit the form
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  on_change_submit()

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Load data from Spreadsheet and fill it.
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  gapi.load 'client',
    callback: ->
      # Handle gapi.client initialization.
      loadGoogleClient("{{ site.google_api_key }}").then ->
        loadDataOfGoogleSpreadsheets("{{ site.spreadsheet_id }}")
      return

  return