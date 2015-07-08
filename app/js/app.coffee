appModule = angular.module 'fantasyDraftHub',
  ['ngAnimate', 'LocalStorageModule', 'ngSanitize', 'ui.router', 'ui.utils', 'ui.select', 'ui.sortable', 'ncy-angular-breadcrumb', 'flash']

appModule.config ($stateProvider, $urlRouterProvider, $httpProvider, localStorageServiceProvider, APP_CONSTANTS, $breadcrumbProvider) ->
  $urlRouterProvider.otherwise('/login');

  $stateProvider
  .state 'login',
    url: '/login'
    templateUrl: '/views/login.html'
    controller: 'loginController'
    resolve:
      echoUrls: (echoUrlService) ->
        echoUrlService.fetchUrls()

  .state 'logout',
    url: '/logout'
    controller: 'logoutController'
    templateUrl: '/views/login.html'

  .state 'forgotPassword',
    url: '/forgot-password'
    controller: 'forgotPasswordController'
    templateUrl: '/views/passwords/forgot.html'
    resolve:
      echoUrls: (echoUrlService) ->
        echoUrlService.fetchUrls()

  .state 'resetPassword',
    url: '/reset-password/:token'
    controller: 'resetPasswordController'
    templateUrl: '/views/passwords/reset.html'
    resolve:
      echoUrls: (echoUrlService) ->
        echoUrlService.fetchUrls()

  .state 'authenticated',
    abstract: true
    url: '/app'
    templateUrl: '/views/authenticated.html'
    controller: 'authenticatedController'
    resolve:
      echoUrls: (echoUrlService) ->
        echoUrlService.fetchUrls()
    data:
      requireLogin: true

  .state 'authenticated.dashboard',
    url: '/dashboard'
    templateUrl: 'views/dashboard.html'
    ncyBreadcrumb:
      label: 'Dashboard'

  .state 'authenticated.customers',
    url: '/customers'
    abstract: true
    templateUrl: 'views/layouts/base-container.html'
    data:
      requirePermission: 'View Customer'

  .state 'authenticated.customers.list',
    url: '/'
    views:
      '':
        templateUrl: 'views/customers/list.html'
        controller: 'customersListController'
      'contextualNavigation@authenticated':
        templateUrl: 'views/customers/_contextual-navigation.html'
        controller: 'contextualNavigationController'
    ncyBreadcrumb:
      label: 'Customers'
      parent: 'authenticated.dashboard'

  .state 'authenticated.customers.new',
    url: '/new'
    templateUrl: 'views/customers/new.html'
    controller: 'customersNewController'
    ncyBreadcrumb:
      label: 'New'
      parent: 'authenticated.customers.list'

  .state 'authenticated.partners',
    url: '/partners'
    abstract: true
    templateUrl: 'views/layouts/base-container.html'

  .state 'authenticated.clinic-manager',
    url: '/clinic-manager'
    template: '<ui-view />'
    abstract: true

  .state 'authenticated.marketing',
    url: '/marketing'
    template: '<ui-view></ui-view>'
    ncyBreadcrumb:
      label: 'Marketing'
      parent: 'authenticated.dashboard'

  .state 'authenticated.onboarding',
    url: '/onboarding'
    abstract: true
    template: '<ui-view></ui-view>'
    ncyBreadcrumb:
      label: 'Onboarding'
      parent: 'authenticated.dashboard'

  .state 'authenticated.program-manager',
    url: '/program-manager'
    abstract: true
    template: '<ui-view></ui-view>'
    ncyBreadcrumb:
      label: 'Program Manager'
      parent: 'authenticated.dashboard'

  $httpProvider.interceptors.push('authRedirector')
  $httpProvider.interceptors.push('authInterceptor')
  $httpProvider.interceptors.push('snakeJsonToCamelCasing')
  if APP_CONSTANTS.env == 'test'
    $httpProvider.interceptors.push ($q, $log) ->
      'request': (config) ->
        $log.debug("#{config.method} #{config.url} #{JSON.stringify(config.data) || ''}")
        config
      'response': (response) ->
        # bail if getting the routes, output is rather verbose
        return response if response.config.url == APP_CONSTANTS.apiUrl

        if typeof response.data == 'object'
          data = JSON.stringify(response.data)
        else
          data = ''
        $log.debug("#{Array(response.config.method.length - 1).join(' ')}-> #{response.config.url} #{response.status} (#{response.statusText}) #{data}")
        response
      'responseError': (rejection) ->
        $log.debug("#{Array(rejection.config.method.length - 1).join(' ')}-> #{rejection.config.url} #{rejection.status} (#{rejection.statusText})")
        $q.reject(rejection)

  localStorageServiceProvider.setPrefix('echo')

  $breadcrumbProvider.setOptions templateUrl: 'views/breadcrumb.html'

appModule.run ($rootScope, $state, authService, sessionService, flashService, routeChangeQueue) ->
  $rootScope.$on '$stateChangeStart', (evt, toState, toParams) ->
    if toState.data and toState.data.requireLogin
      if !authService.isLoggedIn()
        evt.preventDefault()
        $state.go('login')
      else
        if toState.data.requirePermission
          unless sessionService.hasPermission(toState.data.requirePermission)
            evt.preventDefault()
            flashService.error "You don't have permission to access this page"
            $state.go('authenticated.dashboard')

  $rootScope.$on '$stateChangeSuccess', (evt, to, params) ->
    flashService.clear()
    queue = routeChangeQueue.flush()
    func() for func in queue

  $rootScope.$on "$stateChangeError", (event, toState, toParams, fromState, fromParams, error) ->
    if error.status && error.statusText && error.config
      console.error("#{error.config.method} #{error.config.url} #{error.status} (#{error.statusText})")


