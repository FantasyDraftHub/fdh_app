angular.module 'fantasyDraftHub'
  .controller 'fantasyDraftsController', ($scope, $state, $http, APP_CONSTANTS, flashService) ->
    $scope.fantasyDrafts = []
    $scope.fantasyDraft = {}

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_drafts')
    .success (data) ->
      $scope.fantasyDrafts = data

    $scope.saveFantasyDraft = () ->

      if $scope.fantasyDraft.id
        $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$scope.fantasyDraft.id, $scope.fantasyDraft)
        .success (data) ->
          flashService.success 'Awesome! You draft board has been updated!'
          $scope.fantasyDraft = {}
        .error (data) ->
          flashService.error 'Name can\'t be blank'
      else
        $http.post(APP_CONSTANTS.apiUrl+'/fantasy_drafts', $scope.fantasyDraft)
        .success (data) ->
          flashService.success 'Awesome! You draft board has been created.'
          $scope.fantasyDrafts.push(data)
          $scope.fantasyDraft = {}
        .error (data) ->
          flashService.error 'Name can\'t be blank'

    $scope.setFantasyDraft = (fantasyDraft) ->
      $scope.fantasyDraft = fantasyDraft