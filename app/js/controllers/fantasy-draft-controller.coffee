angular.module 'fantasyDraftHub'
  .controller 'fantasyDraftController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, flashService, Pusher) ->
    $scope.fantasyDraft = {}
    $scope.fantasyDraftPick = {}
    $scope.fantasyDraftPicks = []
    $scope.fantasyTeams = []

    $scope.player = {}
    $scope.players = []

    $scope.init = ->
      $http.get(APP_CONSTANTS.apiUrl+'/leagues/1/players')
      .success (data) ->
        $scope.players = data

        $http.get(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/panel')
        .success (data) ->
          $scope.fantasyDraft = data
          $scope.fantasyDraftPicks = data.fantasyDraftPicks
          $scope.fantasyTeams = data.fantasyTeams
          $scope.player = $scope.findPlayerById(data.playerId)
          $scope.buildFantasyDraftPicks()

    $scope.updateFantasyDraft = ->
      $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId, $scope.fantasyDraft)
      .success (data) ->
        $scope.fantasyDraft = data

    $scope.setOnTheBlock = () ->
      $scope.updateFantasyDraft().then ->
        $scope.player = $scope.findPlayerById($scope.fantasyDraft.playerId)

    $scope.unSetOnTheBlock = () ->
      $scope.fantasyDraft.playerId = null
      $scope.updateFantasyDraft().then ->
        $scope.player = {}

    $scope.addDraftPick = ->
      draftPick =
        fantasy_draft_id: $stateParams.fantasyDraftId
        fantasy_team_id: $scope.fantasyDraftPick.fantasyTeam.id
        player_id: $scope.fantasyDraft.playerId
        price: $scope.fantasyDraftPick.price

      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/fantasy_draft_picks', draftPick)
      .success (data) ->

        data.player = $scope.findPlayerById(data.playerId)
        data.fantasyTeam = $scope.findFantasyTeamById(data.fantasyTeamId)
        $scope.fantasyDraftPicks.push(data)

        $scope.player = {}
        $scope.fantasyDraft.playerId = null

    $scope.findPlayerById = (playerId) ->
      tempPlayer = null
      $scope.players.forEach (player, index) ->
        if player.id == playerId
          tempPlayer = player
        return
      tempPlayer

    $scope.findFantasyTeamById = (fantasyTeamId) ->
      tempFantasyTeam = null
      $scope.fantasyTeams.forEach (fantasyTeam, index) ->
        if fantasyTeam.id == fantasyTeamId
          tempFantasyTeam = fantasyTeam
        return
      tempFantasyTeam

    $scope.buildFantasyDraftPicks = ->
      $scope.fantasyDraftPicks.forEach (fantasyDraftPick, index) ->
        $scope.fantasyDraftPicks[index].player = $scope.findPlayerById(fantasyDraftPick.playerId)
        $scope.fantasyDraftPicks[index].fantasyTeam = $scope.findFantasyTeamById(fantasyDraftPick.fantasyTeamId)

    $scope.init()


