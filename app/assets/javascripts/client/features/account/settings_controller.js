'use strict';

angular.module('tdpharmaClientApp')
    .controller('SettingsCtrl', function ($scope, $filter, User, toastr) {
      $scope.errors = {};

      $scope.changePassword = function(form) {
        $scope.submitted = true;
        if(form.$valid) {
          Auth.changePassword( $scope.user.oldPassword, $scope.user.newPassword )
              .then( function() {
                toastr.success($filter('translate')('PASSWORD_CHANGE_SUCCESS'), $filter('translate')('TOASTR_CONGRATS'));
              })
              .catch( function(resp) {
                form.password.$setValidity('mongoose', false);
                $scope.user.oldPassword = '';
                $scope.user.newPassword = '';
                if  (resp.data && resp.data.data && resp.data.data.errors == 'Incorrect Password') {
                  toastr.error($filter('translate')('INCORRECT_PASSWORD'), $filter('translate')('TOASTR_SORRY'));
                }
              });
        }
      };
    });
