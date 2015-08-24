angular.module 'fantasyDraftHub'
  .controller 'fantasyDraftsController', ($scope, $state, $http, APP_CONSTANTS, flashService, $location) ->
    $scope.fantasyDrafts = []
    $scope.fantasyDraft = {}

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_drafts')
    .success (data) ->
      $scope.fantasyDrafts = data

      $scope.fantasyDrafts.forEach (fantasyDraft, index) ->
        $scope.fantasyDrafts[index].urlLink = "http://#{$location.$$host}/#/draft/#{fantasyDraft.url}"


    $scope.saveFantasyDraft = (fantasyDraft) ->
      $scope.formErrors = []
      errors = false

      if !_.has($scope.fantasyDraft, 'name') || $scope.fantasyDraft.name == ''
        $scope.formErrors.push('Draft board name is required.')
        errors = true

      if !_.has($scope.fantasyDraft, 'max') || $scope.fantasyDraft.max == ''
        $scope.formErrors.push('Max dollar amount per team is required.')
        errors = true

      if !_.has($scope.fantasyDraft, 'rounds') || $scope.fantasyDraft.rounds == ''
        $scope.formErrors.push('Total rounds is required.')
        errors = true

      if errors == false
        $('#modal-create-draft').modal('hide')

        if $scope.fantasyDraft.id
          $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$scope.fantasyDraft.id, $scope.fantasyDraft)
          .success (data) ->
            flashService.success 'Awesome! Your draft board has been updated!'
            $scope.fantasyDraft = {}
          .error (data) ->
            flashService.error 'An Error occurred attempting to save the fantasy draft board please try again'
        else
          $http.post(APP_CONSTANTS.apiUrl+'/fantasy_drafts', $scope.fantasyDraft)
          .success (data) ->
            flashService.success 'Awesome! Your draft board has been created.'
            $scope.fantasyDrafts.push(data)
            $scope.fantasyDraft = {}
          .error (data) ->
            flashService.error 'An Error occurred attempting to save the fantasy draft board please try again'
        return

    $scope.setFantasyDraft = (fantasyDraft) ->
      $scope.fantasyDraft = fantasyDraft