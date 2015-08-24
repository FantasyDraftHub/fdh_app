angular.module 'fantasyDraftHub'
  .controller 'fantasyDraftController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, flashService, Pusher) ->
    $scope.fantasyDraft = {}
    $scope.fantasyDraftPick = {}
    $scope.fantasyDraftPicks = []
    $scope.editFantasyDraftPick = {}
    $scope.fantasyTeams = []

    $scope.player = {}
    $scope.players = []
    $scope.availablePlayers = []

    $scope.init = ->

      $http.get(APP_CONSTANTS.apiUrl+'/leagues/1/players?name_only=true')
      .success (data) ->
        $scope.players = data
        $scope.availablePlayers = angular.copy(data)

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

    $scope.setOnTheBlock = (player) ->
      $scope.player = player
      $scope.fantasyDraft.playerId = $scope.player.id
      $scope.updateFantasyDraft()

    $scope.unSetOnTheBlock = () ->
      $scope.fantasyDraft.playerId = null
      $scope.player = null
      $scope.updateFantasyDraft()

    $scope.addDraftPick = ->
      draftPick =
        fantasy_draft_id: $stateParams.fantasyDraftId
        fantasy_team_id: $scope.fantasyDraftPick.fantasyTeam.id
        player_id: $scope.player.id
        price: $scope.fantasyDraftPick.price

      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/fantasy_draft_picks', draftPick)
      .success (data) ->

        data.player = $scope.player
        data.fantasyTeam = $scope.findFantasyTeamById(data.fantasyTeamId)
        $scope.fantasyDraftPicks.push(data)

        $scope.removePlayerFromSelect($scope.player.id)
        $scope.player = null
        $scope.fantasyDraft.playerId = null
        $scope.fantasyDraftPick = {}

    $scope.findPlayerById = (playerId) ->
      tempPlayer = null
      $scope.players.forEach (player, index) ->
        if player.id == playerId
          tempPlayer = player
        return
      tempPlayer

    $scope.findPlayerIndexById = (playerId) ->
      idx = null
      $scope.players.forEach (player, index) ->
        if player.id == playerId
          idx = index
        return
      idx

    $scope.removePlayerFromSelect = (playerId) ->
      $scope.availablePlayers.splice($scope.findPlayerIndexById(playerId),1)


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
        $scope.removePlayerFromSelect(fantasyDraftPick.playerId)

    $scope.setDraftPickEdit = (editFantasyDraftPick) ->
      $scope.editFantasyDraftPick = editFantasyDraftPick

    $scope.updateFantasyDraftPick = (editFantasyDraftPick) ->
      editFantasyDraftPick.fantasyTeamId = editFantasyDraftPick.fantasyTeam.id
      $http.put(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.fantasyDraftId+'/fantasy_draft_picks/'+editFantasyDraftPick.id, editFantasyDraftPick)
      .success (data) ->
        $scope.editFantasyDraftPick = {}

    $scope.isTeamDisabled = (fantasyTeam) ->
      disabled = false
      fantasyDraftPicks = []
      pricePaid = 0

      $scope.fantasyDraftPicks.forEach (fantasyDraftPick, _) ->
        if fantasyDraftPick.fantasyTeamId == fantasyTeam.id
          pricePaid += fantasyDraftPick.price
          fantasyDraftPicks.push(fantasyDraftPick)

      if fantasyDraftPicks.length >= $scope.fantasyDraft.rounds
        disabled = true

      if pricePaid >= $scope.fantasyDraft.max
        disabled = true

      disabled


    $scope.init()


