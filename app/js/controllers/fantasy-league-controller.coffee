angular.module 'fantasyDraftHub'
  .controller 'fantasyLeagueController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, flashService) ->
    $scope.fantasyLeague = {
      fantasyTeams: []
      fantasyDrafts: [
        fantasyDraftOrder: []
      ]
    }
    $scope.newFantasyTeam = {}
    $scope.updateFantasyTeam = {}

    $scope.newFantasyDraft = {}
    $scope.updateFantasyDraft = {}

    $scope.fantasyDraftOrder = []

    $scope.sortableOptions = {
      containment: '#sortable-container'
    }

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId)
    .success (data) ->
      $scope.fantasyLeague = data

      $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams')
      .success (data) ->
        $scope.fantasyLeague.fantasyTeams = data


      $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_drafts')
      .success (data) ->
        $scope.fantasyLeague.fantasyDrafts = data

        $scope.fantasyDraftOrder = angular.copy(data);


    $scope.createFantasyTeam = () ->
      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams', $scope.newFantasyTeam)
      .success (data) ->
        flashService.success 'Team has been created!'
        $scope.fantasyLeague.fantasyTeams.push(data)
        $scope.newFantasyTeam = {}
      .error (data) ->
        flashService.error 'Name can\'t be blank'

    $scope.editFantasyTeam = () ->
      $http.put(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams/'+$scope.updateFantasyTeam.id, $scope.updateFantasyTeam)
      .success (data) ->
        flashService.success 'Team has been updated!'
      .error (data) ->
        flashService.error 'Name can\'t be blank'

      $scope.updateFantasyTeam = {}

    $scope.createFantasyDraft = () ->
      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_drafts', $scope.newFantasyDraft)
      .success (data) ->
        flashService.success 'Draft has been created!'
        $scope.fantasyLeague.fantasyDrafts.push(data)
        $scope.newFantasyDraft = {}
      .error (data) ->
        flashService.error 'Name can\'t be blank'




    $scope.setUpdateFantasyTeam = (fantasyTeam) ->
      $scope.updateFantasyTeam = fantasyTeam



    $scope.saveDraftOrder = () ->
      draftOrder = []
      angular.forEach $scope.fantasyDraftOrder, ((value, key) ->
        @push value.id
        return
      ), draftOrder

      # $http.post(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_drafts/'+$stateParams.fantasyLeagueId+'/fantasy_drafts', $scope.newFantasyDraft)
      # .success (data) ->
      #   flashService.success 'Draft has been created!'
      #   $scope.fantasyLeague.fantasyDrafts.push(data)
      #   $scope.newFantasyDraft = {}
      # .error (data) ->
      #   flashService.error 'Name can\'t be blank'
