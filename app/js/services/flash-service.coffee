angular.module('fantasyDraftHub').factory 'flashService',
  (Flash) ->
    clear: () ->
      Flash.dismiss()

    error: (message) ->
      Flash.create 'danger', message
      @pause()

    errors: (errorMessages) ->
      @error(errorMessages.join('<br />'))

    pause: ->
      Flash.pause()

    resume: ->
      Flash.resume()

    success: (message) ->
      Flash.create 'success', message
      @pause()