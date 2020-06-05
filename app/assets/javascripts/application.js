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
//= require jquery-tablesorter
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


//**************** Tablesorter ********************/

  $("#foamrequests_index_table").tablesorter({
    
    theme : 'green',

    sortList: [[0,1]],

    headers: {
      3: { sorter: 'digit' }, // column number, type
      4: { sorter: 'digit' },
      9 : { sorter: false }
      }
  });  

  $('#new-request-icon').hover(function() {
      $('#new-request-icon-popup').show();
    }, function() {
      $('#new-request-icon-popup').hide();
  });

 
  //**************** Üzenetek ********************/
  $('.message .close').on('click', function() {
    $(this).closest('.message').transition('fade');
  });


  //**************** Semantic UI keresések ********************/
  var newHeader = function (message, type) {
    var
    html = '';
    if (message !== undefined && type !== undefined) {
        html += '' + '<div class="message ' + type + '">';
        // message type
        if (type == 'empty') {
            html += '' + '<div class="header">Nincs találat!</div class="header">' + '<div class="description">' + message + '</div class="description">';
        } else {
            html += ' <div class="description">' + message + '</div>';
        }
        html += '</div>';
    }
    return html;
    };
    
    // the new message header is applied to all following "search" instances
    $.fn.search.settings.templates.message = newHeader;

    $('.ui.search.foamrequest')
    .search({
      apiSettings: {
        url: "//" + location.host + "/foamrequests?search={query}"
      },
      fields: {
        results: 'foamrequests',
        title: 'search_sugesstion',
        url     : 'url'
      },
      minCharacters : 3,
      error : {
        source      : 'Cannot search. No source used, and Semantic API module was not included',
        noResults   : 'Nem található a keresésnek megfelelő rekord!',
        logging     : 'Error in debug logging, exiting.',
        noTemplate  : 'A valid template name was not specified.',
        serverError : 'There was an issue with querying the server.',
        maxResults  : 'Results must be an array to use maxResults setting',
        method      : 'The method you called is not defined.'
      }
    });

})



