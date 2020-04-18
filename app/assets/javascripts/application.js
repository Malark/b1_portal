// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require turbolinks
//= require semantic-ui
//= require_tree .

//**************** Globális funkciók ********************/

function maskDate(source, event) {
  return mask(source, event, '99.99.99', '012345');
}

//---------------------------------------------------  

submit_message = function() {
  $('#labelcheck22').on('keydown', function(e) {
    if (e.keyCode == 13) {
      //alert('You clicked Entrer');
      //$('button').click();
      //$(this).closest('form').submit();
      //e.target.value = "";
    };
  });
  $("#labelcheck2").focus();
};

//**************** Fő folyamat ********************/

$(document).on('turbolinks:load', function () {
  //submit_message();

  $('.ui.dropdown').dropdown();

})



