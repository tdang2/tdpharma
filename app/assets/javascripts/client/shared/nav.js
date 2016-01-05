'use strict';

angular.module('tdpharmaClientApp')
    .controller('NavbarCtrl', function ($scope, $location, $filter, User) {
      User.get().$promise.then(function(data){
        $scope.user = data;
      }).catch(function(error){
        toastr.error(error.error.data);
      });

      $scope.isActive = function(route) {
        return $location.path().indexOf(route) >= 0;
      };
    });