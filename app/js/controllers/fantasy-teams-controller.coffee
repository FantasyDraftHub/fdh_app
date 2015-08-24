angular.module 'fantasyDraftHub'
  .controller 'fantasyTeamsController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, flashService) ->
    $scope.fantasyDraft = {}
    $scope.fantasyTeams = []
    $scope.fantasyTeam = {}

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId)
    .success (data) ->
      $scope.fantasyDraft = data
      $scope.fantasyTeams = angular.copy($scope.fantasyDraft.fantasyTeams)

    $scope.saveFantasyTeam = () ->
      $scope.formErrors = []
      errors = false

      if !_.has($scope.fantasyTeam, 'name') || $scope.fantasyTeam.name == ''
        $scope.formErrors.push('Fantasy Team name is required.')
        errors = true

      if errors == false
        $('#modal-fantasy-team').modal('hide')

        if $scope.fantasyTeam.id
          $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/fantasy_teams/'+$scope.fantasyTeam.id, $scope.fantasyTeam)
          .success (data) ->
            flashService.success 'Awesome! The team has been updated!'
            $scope.fantasyTeam = {}
          .error (data) ->
            flashService.error 'An Error occurred attempting to save the fantasy team please try again'
        else
          $http.post(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/fantasy_teams', $scope.fantasyTeam)
          .success (data) ->
            flashService.success 'Awesome! You have added a new team to your board'
            $scope.fantasyTeams.push(data)
            $scope.fantasyTeam = {}
          .error (data) ->
            flashService.error 'An Error occurred attempting to save the fantasy team please try again'

        return

    $scope.setFantasyTeam = (fantasyTeam) ->
      $scope.fantasyTeam = fantasyTeam

    $scope.sortableOptions =
      containment: '#sortable-container',
      orderChanged: (event) ->
        draftOrder = []
        angular.forEach $scope.fantasyTeams, ((value, key) ->
          @push value.id
          return
        ), draftOrder

        $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId, {draft_order: draftOrder})
        .success (data) ->
          flashService.success 'The Draft Order has been updated.'
